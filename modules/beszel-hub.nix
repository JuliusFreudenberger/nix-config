{
  config,
  lib,
  ...
}:
let

  cfg = config.services.beszel-docker;

in {

  options.services.beszel-docker = {
    enable = lib.mkEnableOption "Beszel hub hosted as OCI container";
    appUrl = lib.mkOption {
      description = "URL of the beszel hub";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      beszel = {
        image = "henrygd/beszel:0.19.0@sha256:fefb27166f5e1611ebf67f8697ea928a23f44efdb00af922e2ac3b5faa2efd5c";
        autoStart = true;
        networks = [
          "traefik"
        ];
        environment = {
          APP_URL = cfg.appUrl;
          DISABLE_PASSWORD_AUTH = "true";
        };
        extraOptions = [
          ''--mount=type=volume,source=data,target=/beszel_data,volume-driver=local''
          /*''--health-cmd=["/beszel" "health" "--url" "http://localhost:8090"]''
          "--health-interval=120s"
          "--health-timeout=5s"
          "--health-retries=2"
          "--health-start-period=10s"*/
        ];
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.beszel.rule" = "Host(`${lib.removePrefix "https://" cfg.appUrl}`)";
          "traefik.http.routers.beszel.entrypoints" = "websecure";
        };
      };
    };

    systemd.services."docker-beszel" = {
      after = [
        "docker-traefik.service"
      ];
      requires = [
        "docker-traefik.service"
      ];
    };

  };
}
