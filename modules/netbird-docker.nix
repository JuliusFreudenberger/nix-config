{
  pkgs,
  utils,
  config,
  lib,
  ...
}:
let

  cfg = config.services.netbird-docker;
  netbirdCfg = config.services.netbird;

in {

  options.services.netbird-docker = {
    enable = lib.mkEnableOption "Netbird Server stack, comprising the dashboard, management API, signal service, relay and STUN server";
    enableLocalAuth = lib.mkEnableOption "local authentication";
    proxy = lib.mkOption {
      description = "Configuration for proxy";
      type = lib.types.submodule {
        options = {
          domain = lib.mkOption {
            description = "Domain the proxy is reachable at. Custom domains will need to add a CNAME record of the wildcard subdomain to this domain.";
            type = lib.types.str;
          };
          token-secret = lib.mkOption {
            description = ''
              Proxy token in env-file notation.
              Name of the environment variable is `NB_PROXY_TOKEN`.
              Create the proxy token after netbird is installed with the following command: docker exec -it netbird-server /go/bin/netbird-server --config /etc/netbird/config.yaml token create --name local
              '';
            type = lib.types.anything;
          };
          extraPorts = lib.mkOption {
            description = ''
              Extra ports to open for L4 routing.
              Ports described in the config (https://docs.netbird.io/selfhosted/migration/enable-reverse-proxy#exposing-l4-ports) can be specified here.
            '';
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
        };
      };
    };
    secrets = lib.mkOption {
      description = ''
        Secret for combined server in env-file notation.
        Name of the relevant environment variables:
          - NETBIRD_RELAY_AUTH_SECRET - Shared authentication secret for relay
          - NETBIRD_DATASTORE_ENC_KEY - Encryption key for sensitive data
      '';
      type = lib.types.anything;
    };
  };

  config = lib.mkIf cfg.enable {
    services.netbird.useRoutingFeatures = lib.mkDefault "server";
    virtualisation.oci-containers.containers = {
      netbird-dashboard = {
        image = "netbirdio/dashboard:v2.90.7";
        autoStart = true;
        networks = [
          "traefik"
        ];
        environment = {
          NETBIRD_MGMT_API_ENDPOINT = "https://${netbirdCfg.server.management.domain}";
          NETBIRD_MGMT_GRPC_API_ENDPOINT = "https://${netbirdCfg.server.management.domain}";
          AUTH_AUDIENCE="netbird-dashboard";
          AUTH_CLIENT_ID="netbird-dashboard";
          AUTH_CLIENT_SECRET="";
          AUTH_AUTHORITY = "https://${netbirdCfg.server.domain}/oauth2";
          USE_AUTH0="false";
          AUTH_SUPPORTED_SCOPES="openid profile email groups";
          AUTH_REDIRECT_URI="/nb-auth";
          AUTH_SILENT_REDIRECT_URI="/nb-silent-auth";
          NGINX_SSL_PORT="443";
          LETSENCRYPT_DOMAIN="none";
        };
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.netbird-dashboard.rule" = "Host(`${netbirdCfg.server.dashboard.domain}`)";
          "traefik.http.routers.netbird-dashboard.entrypoints" = "websecure";
          "traefik.http.routers.netbird-dashboard.tls" = "true";
          "traefik.http.routers.netbird-dashboard.tls.certresolver" = "letsencrypt";
          "traefik.http.routers.netbird-dashboard.service" = "dashboard";
          "traefik.http.routers.netbird-dashboard.priority" = "1";
          "traefik.http.services.dashboard.loadbalancer.server.port" = "80";
        };
        dependsOn = [
          "netbird-server"
        ];
      };
      netbird-server = {
        image = "netbirdio/netbird-server:0.75.0@sha256:9f8dbb2fee412f91acee1a280c6c06fe8a7bea7b615c37530d6a7bba2edcf901";
        autoStart = true;
        networks = [
          "traefik"
        ];
        entrypoint = "/bin/sh";
        cmd = [
          "-c"
          ''sed -e "s|__AUTH_SECRET__|$NETBIRD_RELAY_AUTH_SECRET|" -e "s|__DATASTORE_ENC_KEY__|$NETBIRD_DATASTORE_ENC_KEY|" /etc/netbird/config.yaml.tmpl > /etc/netbird/config.yaml && /go/bin/netbird-server --config /etc/netbird/config.yaml''
        ];
        ports = [
          "3478:3478/udp"
        ];
        volumes = let
          server-config = (pkgs.formats.yaml {}).generate "netbird-server-config" {
            server = {
              listenAddress = ":80";
              exposedAddress = "https://${netbirdCfg.server.domain}:443";
              stunPorts = [ 3478 ];
              metricsPort = 9090;
              healthCheckAddress = ":9000";
              logLevel = netbirdCfg.server.management.logLevel;
              logFile = "console";
              authSecret = "__AUTH_SECRET__";
              dataDir = "/var/lib/netbird";
              auth = {
                issuer = "https://${netbirdCfg.server.dashboard.domain}/oauth2";
                localAuthDisabled = !cfg.enableLocalAuth;
                signKeyRefreshEnabled = true;
                dashboardRedirectURIs = [
                  "https://${netbirdCfg.server.dashboard.domain}/nb-auth"
                  "https://${netbirdCfg.server.dashboard.domain}/nb-silent-auth"
                ];
                cliRedirectURIs = [
                  "http://localhost:53000"
                ];
              };
              reverseProxy.trustedHTTPProxies = [
                "172.18.0.2/32"
              ];
              store = {
                engine = "sqlite";
                encryptionKey = "__DATASTORE_ENC_KEY__";
              };
            };
          };
        in [
          "${server-config}:/etc/netbird/config.yaml.tmpl"
        ];
        environmentFiles = [
          cfg.secrets.path
        ];
        extraOptions = [
          ''--mount=type=volume,source=netbird_data,target=/var/lib/netbird,volume-driver=local''
        ];
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.netbird-grpc.rule" = "Host(`${netbirdCfg.server.signal.domain}`) && (PathPrefix(`/signalexchange.SignalExchange/`) || PathPrefix(`/management.ManagementService/`))";
          "traefik.http.routers.netbird-grpc.entrypoints" = "websecure";
          "traefik.http.routers.netbird-grpc.tls" = "true";
          "traefik.http.routers.netbird-grpc.tls.certresolver" = "letsencrypt";
          "traefik.http.routers.netbird-grpc.service" = "netbird-server-h2c";
          "traefik.http.routers.netbird-grpc.priority" = "100";
          "traefik.http.routers.netbird-backend.rule" = "Host(`${netbirdCfg.server.domain}`) && (PathPrefix(`/relay`) || PathPrefix(`/ws-proxy/`) || PathPrefix(`/api`) || PathPrefix(`/oauth2`))";
          "traefik.http.routers.netbird-backend.entrypoints" = "websecure";
          "traefik.http.routers.netbird-backend.tls" = "true";
          "traefik.http.routers.netbird-backend.tls.certresolver" = "letsencrypt";
          "traefik.http.routers.netbird-backend.service" = "netbird-server";
          "traefik.http.routers.netbird-backend.priority" = "100";
          "traefik.http.services.netbird-server.loadbalancer.server.port" = "80";
          "traefik.http.services.netbird-server-h2c.loadbalancer.server.port" = "80";
          "traefik.http.services.netbird-server-h2c.loadbalancer.server.scheme" = "h2c";
        };
        dependsOn = [
          "traefik"
        ];
      };
      netbird-proxy = {
        image = "netbirdio/reverse-proxy:0.75.0@sha256:967a79b79f6aa8e1882fc08727a69cb338a9ca6b49f1586d4bfe8b6b5a63c9ae";
        autoStart = true;
        ports = [
          "51820:51820/udp"
        ] ++ cfg.proxy.extraPorts;
        networks = [
          "traefik"
        ];
        dependsOn = [
          "netbird-server"
        ];
        environment = {
          NB_PROXY_MANAGEMENT_ADDRESS="http://netbird-server:80";
          NB_PROXY_ALLOW_INSECURE="true";
          NB_PROXY_DOMAIN = cfg.proxy.domain;
          NB_PROXY_ADDRESS = ":8443";
          NB_PROXY_CERTIFICATE_DIRECTORY = "/certs";
          NB_PROXY_ACME_CERTIFICATES = "true";
          NB_PROXY_ACME_CHALLENGE_TYPE = "tls-alpn-01";
          NB_PROXY_FORWARDED_PROTO = "https";
          NB_PROXY_PROXY_PROTOCOL = "true";
          NB_PROXY_TRUSTED_PROXIES = "172.18.0.2";
        };
        environmentFiles = [
          cfg.proxy.token-secret.path
        ];
        extraOptions = [
          ''--mount=type=volume,source=netbird_proxy_certs,target=/certs,volume-driver=local''
        ];
        labels = {
          "traefik.enable" = "true";
          "traefik.tcp.routers.proxy-passthrough.entrypoints" = "websecure";
          "traefik.tcp.routers.proxy-passthrough.rule" = "HostSNI(`*`)";
          "traefik.tcp.routers.proxy-passthrough.tls.passthrough" = "true";
          "traefik.tcp.routers.proxy-passthrough.service" = "proxy-tls";
          "traefik.tcp.routers.proxy-passthrough.priority" = "1";
          "traefik.tcp.services.proxy-tls.loadbalancer.server.port" = "8443";
          "traefik.tcp.services.proxy-tls.loadbalancer.serverstransport" = "pp-v2@file";
        };
      };
    };
  };
}
