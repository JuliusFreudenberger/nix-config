{ inputs, ... }:
{
  age.secrets = {
    inwx.file = "${inputs.secrets}/secrets/dns-management/inwx";
    pocket-id.file = "${inputs.secrets}/secrets/srv03/pocket-id";
    netbird-server.file = "${inputs.secrets}/secrets/srv03/netbird-server";
    netbird-proxy.file = "${inputs.secrets}/secrets/srv03/netbird-proxy";
  };
}
