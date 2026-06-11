{ inputs, ... }:
{
  age.secrets = {
    hawser-token.file = "${inputs.secrets}/secrets/xcy/hawser-token";
    beszel.file = "${inputs.secrets}/secrets/xcy/beszel";
  };
}
