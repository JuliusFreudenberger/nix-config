{
  pkgs,
  lib,
  ...
}: {

  virtualisation = {
    docker = {
      enable = true;
      package = pkgs.docker_29;
      daemon.settings = {
        ipv6 = true;
        ip6tables = true;
      };
    };
    oci-containers.backend = "docker";
  };

}
