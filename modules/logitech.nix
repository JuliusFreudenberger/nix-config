{
  pkgs,
  lib,
  ...
}: {

  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

}
