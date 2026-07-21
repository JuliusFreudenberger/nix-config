{
  pkgs,
  config,
  lib,
  ...
}:
let

  cfg = config.services.traefik-docker;

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
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      traefik = {
        image = "traefik:v3.7.8@sha256:4299bbed850421258fc5448c2e0e6ad350981d4d335a68de11b92448aedbefe5";
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
          "--providers.file.filename=/dynamic-config/providers.yaml"
        ];
        autoStart = true;
        ports = [
          "80:80"
          "443:443"
        ];
        networks = [
          "traefik"
          "docker-socket"
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
        in [
          "/var/run/docker.sock:/var/run/docker.sock"
          "${traefik-providers-config}:/dynamic-config/providers.yaml:ro"
          "/run/traefik/basicAuth.yaml:/dynamic-config/basicAuth.yaml:ro"
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
        image = "tecnativa/docker-socket-proxy:v0.4.2@sha256:1f3a6f303320723d199d2316a3e82b2e2685d86c275d5e3deeaf182573b47476";
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
    };

    systemd.services."docker-traefik" = {
      after = [
        "docker-network-traefik.service"
        "docker-network-docker-socket.service"
      ];
      requires = [
        "docker-network-traefik.service"
        "docker-network-docker-socket.service"
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
      path = [ pkgs.docker_29 ];
      serviceConfig = {
        Type = "oneshot";
      };
      script = ''
        docker network inspect traefik || docker network create traefik --ipv4 --ipv6 --subnet=172.18.0.0/16 --gateway=172.18.0.1
      '';
    };

    systemd.services."docker-network-docker-socket" = {
      path = [ pkgs.docker_29 ];
      serviceConfig = {
        Type = "oneshot";
      };
      script = ''
        docker network inspect docker-socket || docker network create docker-socket --ipv4 --ipv6 --subnet=172.19.0.0/16 --gateway=172.19.0.1
      '';
    };

  };
}
