{
  pkgs-unstable,
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
