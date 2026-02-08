{
  config,
  lib,
  ...
}:
let
  cfg = config.services.dockhand;
in {
  options.services.dockhand = {
    enable = lib.mkEnableOption "dockhand, a powerful, intuitive Docker platform";
    appUrl = lib.mkOption {
      description = "External URL dockhand will be reachable from, without protocol";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      dockhand = {
        image = "fnsys/dockhand:v1.0.12";
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
        ];
        environment = {
          PUID = "1000";
          PGID = "1000";
        };
        networks = [
          "pangolin"
        ];
        labels = {
          "pangolin.public-resources.dockhand.name" = "dockhand";
          "pangolin.public-resources.dockhand.full-domain" = cfg.appUrl;
          "pangolin.public-resources.dockhand.protocol" = "http";
          "pangolin.public-resources.dockhand.auth.sso-enabled" = "true";
          "pangolin.public-resources.dockhand.auth.auto-login-idp" = "1";
          "pangolin.public-resources.dockhand.targets[0].method" = "http";
        };
        extraOptions = [
          ''--mount=type=volume,source=dockhand-data,target=/app/data,volume-driver=local''
          ''--group-add=131'' # docker group
        ];
      };
    };
  };
}
