{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    heroic
  ];

  programs = {
    steam.enable = true;
    gamemode.enable = true;
  };

}
