{
  pkgs,
  config,
  lib,
  ...
}:
let

  cfg = config.services.newt-docker;

in {

  options.services.newt-docker = {
    enable = lib.mkEnableOption "Newt, user space tunnel client for Pangolin";
    pangolinEndpoint = lib.mkOption {
      description = "External URL of the Pangolin instance";
      type = lib.types.str;
    };
    connectionSecret = lib.mkOption {
      description = "Secrets for Pangolin authentication.";
      type = lib.types.anything;
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      newt = {
        image = "fosrl/newt:1.9.0";
        autoStart = true;
        networks = [
          "pangolin"
        ];
        environment = {
          PANGOLIN_ENDPOINT = cfg.pangolinEndpoint;
          DOCKER_SOCKET = "/var/run/docker.sock";
        };
        environmentFiles = [ cfg.connectionSecret.path ];
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock:ro"
        ];
        extraOptions = [
          "--add-host=host.docker.internal:host-gateway"
        ];
      };
    };

    systemd.services."docker-newt" = {
      after = [
        "docker-network-newt.service"
      ];
      requires = [
        "docker-network-newt.service"
      ];
    };

    systemd.services."docker-network-newt" = {
      path = [ pkgs.docker ];
      serviceConfig = {
        Type = "oneshot";
      };
      script = ''
        docker network inspect pangolin || docker network create pangolin --ipv4 --ipv6 --subnet=172.18.0.0/16 --gateway=172.18.0.1
      '';
    };

    networking.firewall.extraCommands = ''
      iptables -A INPUT -p icmp --source 100.89.128.0/24 -j ACCEPT
      iptables -A INPUT -p tcp --source 172.18.0.0/12 --dport 22 -j ACCEPT
    '';

  };
}
