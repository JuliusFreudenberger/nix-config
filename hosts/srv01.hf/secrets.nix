{ inputs, ... }:
{
  age.secrets = {
    teleport-ca_pin.file = "${inputs.secrets}/secrets/teleport/ca_pin";
    teleport-join_token.file = "${inputs.secrets}/secrets/srv01-hf/teleport_auth_token";
    portainer-join_token.file = "${inputs.secrets}/secrets/srv01-hf/portainer_join_token";
    netcup-dns.file = "${inputs.secrets}/secrets/dns-management/netcup";
    pangolin.file = "${inputs.secrets}/secrets/srv01-hf/pangolin";
    newt.file = "${inputs.secrets}/secrets/srv01-hf/newt";
  };
}
