{ inputs, ... }:
{
  age.secrets = {
    hawser-token.file = "${inputs.secrets}/secrets/xcy/hawser-token";
  };
}
