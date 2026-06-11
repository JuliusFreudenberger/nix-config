{ inputs, ... }:
{
  age.secrets = {
    beszel.file = "${inputs.secrets}/secrets/busch/beszel";
  };
}
