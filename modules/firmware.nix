{
  pkgs,
  lib,
  ...
}: {

  services = {
    fwupd.enable = true;
    fstrim.enable = true;
  };

}
