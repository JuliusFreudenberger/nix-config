{
  pkgs,
  lib,
  ...
}: {
  networking = {
    useDHCP = true;
    firewall.allowPing = false;
  };
}
