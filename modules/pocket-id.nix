{
  config,
  lib,
  ...
}:
let

  cfg = config.services.pocket-id-docker;
  pocketidCfg = config.services.pocket-id;

in {

  options.services.pocket-id-docker = {
    enable = lib.mkEnableOption "Pocket ID server hosted as OCI container";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      pocket-id = {
        image = "ghcr.io/pocket-id/pocket-id:v2.13.0@sha256:c9c1d7b70006968d673a1073df048a3fdec73ccb54e182320b56bb911340f6f1";
        autoStart = true;
        networks = [
          "traefik"
        ];
        environment = {
          APP_URL = pocketidCfg.settings.APP_URL;
          TRUST_PROXY = lib.boolToString pocketidCfg.settings.TRUST_PROXY;
          ANALYTICS_DISABLED = lib.boolToString pocketidCfg.settings.ANALYTICS_DISABLED;
          GEOLITE_DB_URL = "https://pkgs.netbird.io/geolocation-dbs/GeoLite2-City/download?suffix=tar.gz";
        };
        environmentFiles = [ pocketidCfg.environmentFile ];
        extraOptions = [
          ''--mount=type=volume,source=data,target=/app/data,volume-driver=local''
          "--health-cmd=/app/pocket-id healthcheck"
          "--health-interval=1m30s"
          "--health-timeout=5s"
          "--health-retries=2"
          "--health-start-period=10s"
        ];
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.pocket-id.rule" = "Host(`${lib.removePrefix "https://" pocketidCfg.settings.APP_URL}`)";
          "traefik.http.routers.pocket-id.entrypoints" = "websecure";
        }; 
      };
    };

    systemd.services."docker-pocket-id" = {
      after = [
        "docker-traefik.service"
      ];
      requires = [
        "docker-traefik.service"
      ];
    };

  };
}
