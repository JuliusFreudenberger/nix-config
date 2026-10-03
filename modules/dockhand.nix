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
        image = "fnsys/dockhand:v1.0.51@sha256:ffba7083c8d28ae7afdc3c30e89ee03d43fa6ee99c335ee25e8cfab8b767f431";
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
        ];
        environment = {
          PUID = "1000";
          PGID = "1000";
        };
        networks = [
          "webproxy"
        ];
        extraOptions = [
          ''--mount=type=volume,source=dockhand-data,target=/app/data,volume-driver=local''
          ''--group-add=${toString config.ids.gids.docker}''
        ];
      };
    };
  };
}
