{
  pkgs,
  lib,
  ...
}: {
  networking = {
    useDHCP = true;
  };
}
