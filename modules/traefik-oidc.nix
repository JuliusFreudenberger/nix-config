{
  pkgs,
  config,
  lib,
  ...
}:
let

  cfg = config.services.traefik-docker;

  mapOidcClientNameToEnv = stringToReplace: lib.replaceString "-" "_" (lib.toUpper stringToReplace);

  traefik-mtls-config = (pkgs.formats.yaml { }).generate "traefik-mtls-config" {
    tls.options.default.clientAuth = {
      caFiles = "caFiles/root_ca.crt";
      clientAuthType = "VerifyClientCertIfGiven";
    };
  };

in {

  options.services.traefik-docker = {
    enable = lib.mkEnableOption "traefik web server hosted as OCI container";
    dashboardUrl = lib.mkOption {
      description = "External URL the traefik dashboard will be reachable from, without protocol";
      type = lib.types.str;
    };
    dnsSecrets = lib.mkOption {
      description = "Secrets for DNS providers.";
      type = lib.types.listOf lib.types.anything;
    };
    mTLSCaCertSecret = lib.mkOption {
      description = "Agenix secret containing the CA file to verify client certificates against.";
    };
    oidcAuthProviderUrl = lib.mkOption {
      description = "Provider URL of OIDC auth provider.";
      type = lib.types.str;
    };
    oidcClients = lib.mkOption {
      example = ''
        immich = {
          scopes = [
            "openid"
            "email"
            "profile"
          ];
          enableBypassUsingClientCertificate = true;
          usePkce = true;
        };
      '';
      description = "Attribute set of OIDC clients with their configurations.";
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            secret = lib.mkOption {
              description = ''Agenix secret containing the following needed environment variables in dotenv notation:
                 - <clientName>_OIDC_AUTH_SECRET
                 - <clientName>_OIDC_AUTH_PROVIDER_CLIENT_ID
                 - <clientName>_OIDC_CLIENT_SECRET
              '';
            };
            scopes = lib.mkOption {
              default = [ "openid" ];
              example = [ "openid" "email" "profile" "groups" ];
              description = "OIDC scopes to request from auth provider.";
              type = lib.types.listOf lib.types.str;
            };
            usePkce = lib.mkOption {
              default = true;
              description = "Whether to enable PKCE for this provider.";
              type = lib.types.bool;
            };
            enableBypassUsingClientCertificate = lib.mkOption {
              default = false;
              description = "Whether to allow bypassing OIDC protection when a verified client certificate is presented.";
              type = lib.types.bool;
            };
            useClaimsFromUserInfo = lib.mkOption {
              default = false;
              description = "When enabled, an additional request to the provider's userinfo_endpoint is made to validate the token and to retrieve additional claims. The userinfo claims are merged directly into the token claims, with userinfo values overriding token values for non-security-critical claims.";
              type = lib.types.bool;
            };
            headers = lib.mkOption {
              default = [];
              description = "Headers to be added to the upstream request. Templating is possible. Documentation can be found here: https://traefik-oidc-auth.sevensolutions.cc/docs/getting-started/middleware-configuration";
              type = lib.types.listOf (lib.types.submodule {
                options = {
                  Name = lib.mkOption {
                    description = "The name of the header which should be added to the upstream request.";
                    type = lib.types.str;
                  };
                  Value = lib.mkOption {
                    description = "The value of the header, which can use Go-Templates.";
                    type = lib.types.str;
                  };
                };
              });
            };
          };
        }
      );
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      traefik = {
        image = "traefik:v3.6.6";
        cmd = [
          "--providers.docker=true"
          "--providers.docker.exposedByDefault=false"
          "--providers.docker.network=traefik"
          "--providers.file.directory=/dynamic-config"
          "--log.level=INFO"
          "--api=true"
          "--ping=true"
          "--entrypoints.web.address=:80"
          "--entrypoints.websecure.address=:443"
          "--entrypoints.websecure.transport.respondingTimeouts.readTimeout=600s"
          "--entrypoints.websecure.transport.respondingTimeouts.idleTimeout=600s"
          "--entrypoints.websecure.transport.respondingTimeouts.writeTimeout=600s"
          "--entrypoints.web.http.redirections.entrypoint.to=websecure"
          "--entrypoints.websecure.asDefault=true"
          "--entrypoints.websecure.http.middlewares=strip-mtls-headers@docker,pass-tls-client-cert@docker"
          "--entrypoints.websecure.http.tls.certresolver=letsencrypt"
          "--certificatesresolvers.letsencrypt.acme.storage=/certs/acme.json"
          "--certificatesresolvers.letsencrypt.acme.dnschallenge=true"
          "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=netcup"
          "--experimental.plugins.traefik-oidc-auth.modulename=github.com/sevensolutions/traefik-oidc-auth"
          "--experimental.plugins.traefik-oidc-auth.version=v0.17.0"
        ];
        autoStart = true;
        ports = [
          "80:80"
          "443:443"
        ];
        networks = [
          "traefik"
        ];
        environment = {
          OIDC_AUTH_PROVIDER_URL = cfg.oidcAuthProviderUrl;
        };
        environmentFiles = lib.forEach cfg.dnsSecrets (secret: secret.path) ++ (lib.mapAttrsToList (oidcClientName: oidcClientConfig: oidcClientConfig.secret.path) cfg.oidcClients);
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.dashboard.rule" = "Host(`${cfg.dashboardUrl}`)";
          "traefik.http.routers.dashboard.service" = "dashboard@internal";
          "traefik.http.routers.dashboard.middlewares" = "traefik-dashboard-oidc-auth@file";
          "traefik.http.routers.api.rule" = "Host(`${cfg.dashboardUrl}`) && (PathPrefix(`/api`) || PathPrefix(`/oidc/callback`))";
          "traefik.http.routers.api.service" = "api@internal";
          "traefik.http.routers.api.middlewares" = "traefik-dashboard-oidc-auth@file";
          "traefik.http.middlewares.strip-mtls-headers.headers.customrequestheaders.X-Forwarded-Tls-Client-Cert" = "";
          "traefik.http.middlewares.pass-tls-client-cert.passtlsclientcert.pem" = "true";
        };
        volumes = let
          oidc-config = lib.mapAttrs' (
            oidcClientName: oidcClientConfig:
            lib.nameValuePair "${oidcClientName}-oidc-auth" {
              plugin.traefik-oidc-auth = {
                LogLevel = "INFO";
                Secret = ''{{ env "${mapOidcClientNameToEnv oidcClientName}_OIDC_AUTH_SECRET" }}'';
                Provider = {
                  Url = ''{{ env "OIDC_AUTH_PROVIDER_URL" }}'';
                  ClientId = ''{{ env "${mapOidcClientNameToEnv oidcClientName}_OIDC_AUTH_PROVIDER_CLIENT_ID" }}'';
                  ClientSecret = ''{{ env "${mapOidcClientNameToEnv oidcClientName}_OIDC_AUTH_PROVIDER_CLIENT_SECRET" }}'';
                  UsePkce = oidcClientConfig.usePkce;
                  UseClaimsFromUserInfo = oidcClientConfig.useClaimsFromUserInfo;
                };
                Scopes = oidcClientConfig.scopes;
                LoginUrl = ''{{ env "OIDC_AUTH_PROVIDER_URL" }}'';
              } // (lib.attrsets.optionalAttrs oidcClientConfig.enableBypassUsingClientCertificate {
                BypassAuthenticationRule = "HeaderRegexp(`X-Forwarded-Tls-Client-Cert`, `.+`)";
              }) // (lib.attrsets.optionalAttrs ((lib.length oidcClientConfig.headers) > 0) {
                Headers = oidcClientConfig.headers;
              });
            }
          ) cfg.oidcClients;
          traefik-oidc-authentication-config = (pkgs.formats.yaml {}).generate "traefik-oidc-auth" {
            http.middlewares = oidc-config;
          };
        in [
          "/var/run/docker.sock:/var/run/docker.sock"
          "${traefik-oidc-authentication-config}:/dynamic-config/traefik-oidc-auth.yaml:ro"
          "${traefik-mtls-config}:/dynamic-config/traefik-mtls.yaml:ro"
          "${cfg.mTLSCaCertSecret.path}:/caFiles/root_ca.crt:ro"
        ];
        extraOptions = [
          ''--mount=type=volume,source=certs,target=/certs,volume-driver=local''
          "--add-host=host.docker.internal:host-gateway"
          "--health-cmd=wget --spider --quiet http://localhost:8080/ping"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=3"
          "--health-start-period=5s"
        ];
      };
    };

    systemd.services."docker-traefik" = {
      after = [
        "docker-network-traefik.service"
      ];
      requires = [
        "docker-network-traefik.service"
      ];
    };

    systemd.services."docker-network-traefik" = {
      path = [ pkgs.docker ];
      serviceConfig = {
        Type = "oneshot";
      };
      script = ''
        docker network inspect traefik || docker network create traefik --ipv4 --ipv6 --subnet=172.18.0.0/16 --gateway=172.18.0.1
      '';
    };

    networking.firewall.extraCommands = "iptables -t nat -I PREROUTING -s 172.18.0.0/16 -d 172.18.0.0/16 -j MASQUERADE";

  };
}
