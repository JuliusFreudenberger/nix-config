{
  pkgs,
  config,
  lib,
  ...
}:
let

  cfg = config.services.traefik-docker;

  bouncerKey = "crowdsecbouncerkeytraefik";

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
    dnsChallengeProvider = lib.mkOption {
      description = "Name of provider for DNS challenge.";
      type = lib.types.str;
    };
    enableCrowdsec = lib.mkEnableOption "crowdsec and traefik bouncer plugin";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      traefik = {
        image = "traefik:v3.7.13@sha256:f86a2cab1b5c649070c49f883c743dd32d8485a56e3368c5f93b9e91f1e91259";
        cmd = [
          "--providers.docker=true"
          "--providers.docker.endpoint=http://docker-socket-proxy:2375"
          "--providers.docker.exposedByDefault=false"
          "--providers.docker.network=traefik"
          "--providers.file.directory=/dynamic-config"
          "--log.level=INFO"
          "--api=true"
          "--ping=true"
          "--entrypoints.web.address=:80"
          "--entrypoints.websecure.address=:443"
          "--entrypoints.websecure.transport.respondingTimeouts.readTimeout=0"
          "--entrypoints.websecure.transport.respondingTimeouts.idleTimeout=0"
          "--entrypoints.websecure.transport.respondingTimeouts.writeTimeout=0"
          "--serverstransport.forwardingtimeouts.responseheadertimeout=0s"
          "--serverstransport.forwardingtimeouts.idleconntimeout=0s"
          "--entrypoints.web.http.redirections.entrypoint.to=websecure"
          "--entrypoints.websecure.asDefault=true"
          "--entrypoints.websecure.http.tls.certresolver=letsencrypt"
          "--certificatesresolvers.letsencrypt.acme.email=contact@jfreudenberger.de"
          "--certificatesresolvers.letsencrypt.acme.storage=/certs/acme.json"
          "--certificatesresolvers.letsencrypt.acme.dnschallenge=true"
          "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=${cfg.dnsChallengeProvider}"
          "--certificatesresolvers.letsencrypt.acme.dnschallenge.propagation.requireALLRNS=false" # https://github.com/traefik/traefik/issues/13697#issuecomment-5346551729
          "--providers.file.filename=/dynamic-config/providers.yaml"
        ] ++ lib.optionals cfg.enableCrowdsec [
          "--experimental.plugins.bouncer.modulename=github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin"
          "--experimental.plugins.bouncer.version=v1.7.1"
        ];
        autoStart = true;
        dependsOn = lib.mkIf cfg.enableCrowdsec [ "crowdsec" ];
        ports = [
          "80:80"
          "443:443"
        ];
        networks = [
          "traefik"
          "docker-socket"
        ] ++ lib.optionals cfg.enableCrowdsec [
          "crowdsec"
        ];
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.dashboard.rule" = "Host(`${cfg.dashboardUrl}`)";
          "traefik.http.routers.dashboard.entrypoints" = "websecure";
          "traefik.http.routers.dashboard.service" = "api@internal";
          "traefik.http.routers.dashboard.middlewares" = "auth@file";
        };
        environmentFiles = lib.forEach cfg.dnsSecrets (secret: secret.path);
        volumes = let
          traefik-providers-config = (pkgs.formats.yaml {}).generate "traefik-providers-config" {
            tcp.serversTransports.pp-v2.proxyProtocol.version = 2;
          };
          traefik-crowdsec-plugin-config = (pkgs.formats.yaml {}).generate "traefik-crowdsec-plugin-config" {
            http.middlewares.crowdsec.plugin.bouncer = {
              enabled = true;
              crowdseclapikey = bouncerKey;
              crowdsecmode = "stream";
              loglevel = "INFO";
            };
          };
        in [
          "/var/run/docker.sock:/var/run/docker.sock"
          "${traefik-providers-config}:/dynamic-config/providers.yaml:ro"
          "/run/traefik/basicAuth.yaml:/dynamic-config/basicAuth.yaml:ro"
        ] ++ lib.optionals cfg.enableCrowdsec [
          "${traefik-crowdsec-plugin-config}:/dynamic-config/crowdsec.yaml:ro"
        ];
        extraOptions = [
          ''--mount=type=volume,source=certs,target=/certs,volume-driver=local''
          "--ip=172.18.0.2"
          "--add-host=host.docker.internal:host-gateway"
          "--health-cmd=wget --spider --quiet http://localhost:8080/ping"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=3"
          "--health-start-period=5s"
        ];
      };
      docker-socket-proxy = {
        image = "tecnativa/docker-socket-proxy:v0.5.0@sha256:1f5038b54f06c3e18422902cf00ba21803d1c97805aae032e5e6673d532d3459";
        autoStart = true;
        networks = [
          "docker-socket"
        ];
        environment = {
          CONTAINERS = "1";
        };
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock:ro"
        ];
      };
      crowdsec = lib.mkIf cfg.enableCrowdsec {
        image = "crowdsecurity/crowdsec:v1.7.7@sha256:6ca53ad26196ca59ddd4fa692a586b73d8fcde085046163b9ca2f04887dca563";
        autoStart = true;
        networks = [
          "crowdsec"
        ];
        environment = {
          COLLECTIONS = "crowdsecurity/traefik";
          BOUNCER_KEY_traefik = bouncerKey;
        };
        extraOptions = [
          ''--mount=type=volume,source=crowdsec_config,target=/etc/crowdsec,volume-driver=local''
          ''--mount=type=volume,source=crowdsec_db,target=/var/lib/crowdsec/data,volume-driver=local''
          ''--health-cmd=cscli lapi status''
          ''--health-interval=10s''
          ''--health-timeout=5s''
          ''--health-retries=15''
        ];
        labels = {
          "traefik.enable" = "false";
        };
      };
    };

    systemd.services.${config.virtualisation.oci-containers.containers.traefik.serviceName} = {
      restartIfChanged = false;
      after = [
        "docker-network-traefik.service"
        "docker-network-docker-socket.service"
      ] ++ lib.optionals cfg.enableCrowdsec [
        "docker-network-crowdsec.service"
      ];
      requires = [
        "docker-network-traefik.service"
        "docker-network-docker-socket.service"
      ] ++ lib.optionals cfg.enableCrowdsec [
        "docker-network-crowdsec.service"
      ];
    };

    systemd.services.generate-traefik-config = {
      description = "Generate Traefik basic auth config";
      wantedBy = [ "multi-user.target" ];
      before = [ "docker-traefik.service" ];

      serviceConfig.Type = "oneshot";

      script = ''
        set -eu
        mkdir -p /run/traefik

        BASIC_AUTH="$(cat ${config.age.secrets.traefik-basic-auth.path})"

        cat > /run/traefik/basicAuth.yaml <<EOF
http:
  middlewares:
    auth:
      basicAuth:
        users:
          - "$BASIC_AUTH"
EOF
      '';
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

    systemd.services."docker-network-docker-socket" = {
      path = [ pkgs.docker ];
      serviceConfig = {
        Type = "oneshot";
      };
      script = ''
        docker network inspect docker-socket || docker network create docker-socket --ipv4 --ipv6 --subnet=172.19.0.0/16 --gateway=172.19.0.1
      '';
    };

    systemd.services."docker-network-crowdsec" = lib.mkIf cfg.enableCrowdsec {
      path = [ pkgs.docker ];
      serviceConfig = {
        Type = "oneshot";
      };
      script = ''
        docker network inspect crowdsec || docker network create crowdsec
      '';
    };

  };
}
