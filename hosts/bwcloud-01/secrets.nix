{ inputs, ... }:
{
  age.secrets = {
    netcup-dns.file = "${inputs.secrets}/secrets/dns-management/netcup";
    traefik-basic-auth.file = "${inputs.secrets}/secrets/bwcloud-01/traefik-basic-auth";
  };
}
