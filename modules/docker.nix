{
  pkgs,
  lib,
  ...
}: {

  virtualisation = {
    docker = {
      enable = true;
      daemon.settings = {
        ipv6 = true;
        ip6tables = true;
      };
    };
    oci-containers.backend = "docker";
  };

}
