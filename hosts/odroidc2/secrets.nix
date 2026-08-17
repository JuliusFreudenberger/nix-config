{ inputs, ... }:
{
  age.secrets = {
    hawser-token.file = "${inputs.secrets}/secrets/odroidc2/hawser-token";
    beszel.file = "${inputs.secrets}/secrets/odroidc2/beszel";
  };
}
