{ inputs, ... }:
{
  age.secrets = {
    hawser-token.file = "${inputs.secrets}/secrets/busch-gpu-docker/hawser-token";
    beszel.file = "${inputs.secrets}/secrets/busch-gpu-docker/beszel";
  };
}
