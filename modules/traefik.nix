{
  pkgs,
  config,
  lib,
  ...
}:
let

  cfg = config.services.traefik-docker;
  version = "3.6.14";

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
        image = "traefik:v${version}";
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
        environmentFiles = lib.forEach cfg.dnsSecrets (secret: secret.path);
        volumes = let
          traefik-providers-config = (pkgs.formats.yaml {}).generate "traefik-providers-config" {
            tcp.serversTransports.pp-v2.proxyProtocol.version = 2;
          };
        in [
          "/var/run/docker.sock:/var/run/docker.sock"
          "${traefik-providers-config}:/dynamic-config/providers.yaml:ro"
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
        image = "tecnativa/docker-socket-proxy:v0.4.2";
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
