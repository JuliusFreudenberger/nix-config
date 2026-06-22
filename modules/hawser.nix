{
  config,
  lib,
  ...
}:
let
  cfg = config.services.hawser;
in {
  options.services.hawser = {
    enable = lib.mkEnableOption "hawser, the agent for Dockhand";
    agentName = lib.mkOption {
      description = "Name of the hawser agent";
      default = config.networking.hostName;
      type = lib.types.str;
    };
    dockhandServerUrl = lib.mkOption {
      description = "Websocket endpoint the hawser agent can use to connect to dockhand.";
      example = "wss://your-dockhand.example.com/api/hawser/connect";
      type = lib.types.str;
    };
    tokenSecretFile = lib.mkOption {
      description = "Agenix secret containing the token as environment variable TOKEN";
      type = lib.types.anything;
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      hawser = {
        image = "ghcr.io/finsys/hawser:0.2.42@sha256:79f926e8d8fe31c0dfe90858f90b69bfd4cfbb113472605620b91a4b444dd557";
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
        ];
        environment = {
          STACKS_DIR = "/opt/hawser-stacks";
          DOCKHAND_SERVER_URL = cfg.dockhandServerUrl;
          AGENT_NAME = cfg.agentName;
        };
        environmentFiles = [
          cfg.tokenSecretFile.path
        ];
        extraOptions = [
          ''--mount=type=volume,source=hawser-data,target=/opt/hawser-stacks,volume-driver=local''
        ];
      };
    };
  };
}
