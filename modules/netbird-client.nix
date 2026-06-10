{
  pkgs,
  pkgs-unstable,
  utils,
  config,
  lib,
  ...
}:
let

  cfg = config.services.netbird-client;

  clientVersion = "0.71.2";

  clientConfiguration = lib.types.submodule {
    options = {
      setupKey = lib.mkOption {
        description = "Setup Key for this client";
        type = lib.types.str;
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
    services.netbird = {
      package = pkgs-unstable.netbird;
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
    systemd.services.${config.services.netbird.clients.wt0.service.name}.path = [ pkgs.shadow ];

    services.resolved.enable = true;

    virtualisation.oci-containers.containers = {
      netbird = {
        image = "netbirdio/netbird:${clientVersion}-rootless";
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

    systemd.services."docker-netbird" = {
      after = [
        "docker-network-webproxy.service"
      ];
      requires = [
        "docker-network-webproxy.service"
      ];
    };


    systemd.services."docker-network-webproxy" = {
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
