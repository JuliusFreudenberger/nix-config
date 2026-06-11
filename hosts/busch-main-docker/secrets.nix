{ inputs, ... }:
{
  age.secrets = {
    hawser-token.file = "${inputs.secrets}/secrets/busch-main-docker/hawser-token";
    beszel.file = "${inputs.secrets}/secrets/busch-main-docker/beszel";
  };
}
