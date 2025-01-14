{
  pkgs,
  lib,
  ...
}: {

  programs.kdeconnect = {
    enable = true;
    package = pkgs.valent;
  };

}
