{
  pkgs,
  lib,
  config,
  nodename,
  ...
}: let
  cfg = config.services.teleport;
  in {

  config = lib.mkIf config.services.teleport.enable {
    environment.systemPackages = [ cfg.package ];

    services.teleport = {
      package = pkgs.teleport_17;
      settings = {
        teleport = {
          nodename = config.networking.hostName;
          auth_servers = [ "tp.jfreudenberger.de:3023" ];
          log.severity = "ERROR";
        };
        ssh_service = {
          enabled = true;
          permit_user_env = true;
          commands = [
            {
              name = "hostname";
              command = ["${pkgs.nettools}/bin/hostname"];
              period = "1h";
            }
            {
              name = "IP";
              command = ["${pkgs.curl}/bin/curl" "ifconfig.me"];
              period = "1h";
            }
            {
              name = "UP";
              command = ["${pkgs.bash}/bin/bash" "-c" "${pkgs.procps}/bin/uptime -p | ${pkgs.coreutils}/bin/cut -c4- | ${pkgs.coreutils}/bin/cut -d',' -f1"];
              period = "1h";
            }
            {
              name = "teleport-version";
              command = ["${pkgs.bash}/bin/bash" "-c" "${cfg.package}/bin/teleport version | ${pkgs.coreutils}/bin/cut -d' ' -f2"];
              period = "12h";
            }
          ];
        };
        proxy_service.enabled = false;
        auth_service.enabled = false;
      };
    };
  };
}
