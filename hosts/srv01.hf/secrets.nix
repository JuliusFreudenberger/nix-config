{ inputs, ... }:
{
  age.secrets = {
    teleport-ca_pin.file = "${inputs.secrets}/secrets/teleport/ca_pin";
    teleport-join_token.file = "${inputs.secrets}/secrets/srv01-hf/teleport_auth_token";
    portainer-join_token.file = "${inputs.secrets}/secrets/srv01-hf/portainer_join_token";
    netcup-dns.file = "${inputs.secrets}/secrets/dns-management/netcup";
    traefik-oidc-auth.file = "${inputs.secrets}/secrets/srv01-hf/traefik-oidc-auth";
    immich-oidc-auth.file = "${inputs.secrets}/secrets/srv01-hf/immich-oidc-auth";
    arcane-oidc-auth.file = "${inputs.secrets}/secrets/srv01-hf/arcane-oidc-auth";
    arcane-secrets.file = "${inputs.secrets}/secrets/srv01-hf/arcane-secrets";
    firefly-oidc-auth.file = "${inputs.secrets}/secrets/srv01-hf/firefly-oidc-auth";
    step-ca-crt.file = "${inputs.secrets}/secrets/step-ca/step-ca-crt";
  };
}
