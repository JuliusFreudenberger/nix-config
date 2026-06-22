{
  pkgs,
  utils,
  config,
  lib,
  ...
}:
let

  cfg = config.services.netbird-client;

  clientConfiguration = lib.types.submodule {
    options = {
      setupKey = lib.mkOption {
        description = "Setup Key for this client";
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
    };
  };

in {

  options.services.netbird-client = {
    enable = lib.mkEnableOption "Netbird client, with possiblities for host connection and for docker based connection.";
    managementUrl = lib.mkOption {
      description = "Management URL of netbird server.";
      type = lib.types.str;
    };
    host = lib.mkOption {
      description = "Configuration for host connection";
      type = clientConfiguration;
    };
    docker = lib.mkOption {
      description = "Configuration for docker connection";
      type = clientConfiguration;
    };
    dockerSubnet = lib.mkOption {
      description = "Second part of ipv4 subnet";
      type = lib.types.str;
      default = "20";
    };
  };

  config = lib.mkIf cfg.enable {
    services.netbird = lib.mkIf (cfg.host.setupKey != null) {
      useRoutingFeatures = "both";
      clients.wt0 = {
        hardened = false;
        login = {
          enable = true;
          setupKeyFile = (pkgs.writeText "setupKey" cfg.host.setupKey).outPath;
        };
        port = 51820;
        environment = {
          NB_MANAGEMENT_URL = cfg.managementUrl;
        };
      };
    };

    services.resolved.enable = lib.mkIf (cfg.host.setupKey != null) true;

    virtualisation.oci-containers.containers = lib.mkIf (cfg.docker.setupKey != null) {
      netbird = {
        image = "netbirdio/netbird:v0.73.2-rootless@sha256:4f1893ea708f7f0cdafc6f77f400415e2a81350db57f0fa74dda3c2d6bd02772";
        autoStart = true;
        hostname = "${config.networking.hostName}-docker";
        networks = [
          "webproxy"
        ];
        environment = {
          NB_MANAGEMENT_URL = cfg.managementUrl;
          PEER_NAME = "${config.networking.hostName}-docker";
          NB_SETUP_KEY = cfg.docker.setupKey;
        };
        extraOptions = [
          ''--mount=type=volume,source=netbird_client_data,target=/var/lib/netbird,volume-driver=local''
        ];
      };
    };

    systemd.services."docker-netbird" = lib.mkIf (cfg.docker.setupKey != null) {
      after = [
        "docker-network-webproxy.service"
      ];
      requires = [
        "docker-network-webproxy.service"
      ];
    };


    systemd.services."docker-network-webproxy" = lib.mkIf (cfg.docker.setupKey != null) {
      path = [ pkgs.docker_29 ];
      serviceConfig = {
        Type = "oneshot";
      };
      script = ''
        docker network inspect webproxy || docker network create webproxy --ipv4 --ipv6 --subnet=172.${cfg.dockerSubnet}.0.0/16 --gateway=172.${cfg.dockerSubnet}.0.1
      '';
    };
  };
}
