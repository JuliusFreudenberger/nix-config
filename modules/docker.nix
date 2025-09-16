{
  pkgs,
  lib,
  ...
}: {

  virtualisation = {
    docker = {
      enable = true;
    };
    oci-containers.backend = "docker";
  };

}
