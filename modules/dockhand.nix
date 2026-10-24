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
        image = "fnsys/dockhand:v1.0.55@sha256:039fbb65899f5ecc1d63083736d94587306b35736bca666eca623416859ddaa5";
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
