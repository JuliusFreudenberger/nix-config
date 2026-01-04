{
  config,
  lib,
  ...
}:
let
  cfg = config.services.arcane;
in {
  options.services.arcane = {
    enable = lib.mkEnableOption "arcane, a modern Docker management UI";
    appUrl = lib.mkOption {
      description = "External URL arcane will be reachable from, without protocol";
      type = lib.types.str;
    };
    secretFile = lib.mkOption {
      description = ''
        Agenix secret containing the following needed environment variables in dotenv notation:
          - ENCRYPTION_KEY
          - JWT_SECRET
          - OIDC_CLIENT_ID
          - OIDC_CLIENT_SECRET
          - OIDC_ISSUER_URL
          - OIDC_ADMIN_CLAIM
          - OIDC_ADMIN_VALUE
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      arcane = {
        image = "ghcr.io/getarcaneapp/arcane:v1.11.2";
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
        ];
        environment = {
          APP_URL = "https://${cfg.appUrl}";
          PUID = "1000";
          PGID = "1000";
          LOG_LEVEL = "info";
          LOG_JSON = "false";
          OIDC_ENABLED = "true";
          OIDC_SCOPES = "openid email profile groups";
          DATABASE_URL = "file:data/arcane.db?_pragma=journal_mode(WAL)&_pragma=busy_timeout(2500)&_txlock=immediate";
        };
        environmentFiles = [
          cfg.secretFile.path
        ];
        networks = [
          "traefik"
        ];
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.arcane.middlewares" = "arcane-oidc-auth@file";
          "traefik.http.routers.arcane.rule" = "Host(`${cfg.appUrl}`)";
          "traefik.http.services.arcane.loadbalancer.server.port" = "3552";
        };
        extraOptions = [
          ''--mount=type=volume,source=arcane-data,target=/app/data,volume-driver=local''
        ];
      };
    };
  };
}
