{ inputs, ... }:
{
  age.secrets = {
    beszel.file = "${inputs.secrets}/secrets/busch-forgejo-actions-runner/beszel";
    forgejo-actions-runner-own-1.file = "${inputs.secrets}/secrets/busch-forgejo-actions-runner/runner-own-1";
  };
}
