{ inputs, ... }:
{
  age.secrets = {
    beszel.file = "${inputs.secrets}/secrets/busch-nixos-native/beszel";
    renovate-token.file = "${inputs.secrets}/secrets/busch-nixos-native/renovate-token";
    renovate-github-com-token.file = "${inputs.secrets}/secrets/busch-nixos-native/renovate-github-com-token";
  };
}
