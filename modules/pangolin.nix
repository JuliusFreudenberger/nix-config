{
  pkgs-unstable,
  utils,
  config,
  lib,
  ...
}: {

  services = {
    pangolin = {
      enable = true;
      package = pkgs-unstable.fosrl-pangolin;
      openFirewall = true;
      settings = {
        app = {
          save_logs = true;
          log_failed_attempts = true;
        };
        domains = {
          domain1 = {
            prefer_wildcard_cert = true;
          };
        };
        flags = {
          disable_signup_without_invite = true;
          disable_user_create_org = true;
        };
      };
    };
  };

  systemd.services.gerbil.serviceConfig.ExecStart = lib.mkForce (utils.escapeSystemdExecArgs [
    (lib.getExe pkgs-unstable.fosrl-gerbil)
    "--reachableAt=http://localhost:${toString config.services.gerbil.port}"
    "--generateAndSaveKeyTo=${toString config.services.pangolin.dataDir}/config/key"
    "--remoteConfig=http://localhost:3001/api/v1/gerbil/get-config"
  ]);

}

# Settings needed on the host
#
#  services = {
#    pangolin = {
#      dnsProvider = "";
#      baseDomain = "";
#      letsEncryptEmail = "";
#      environmentFile = config.age.secrets."".path;
#    };
#    traefik = {
#      environmentFiles = [ config.age.secrets."".path ];
#    };
#  };
