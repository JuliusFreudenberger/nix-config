{
  pkgs,
  lib,
  config,
  ...
}: {
  home.packages = with pkgs; [
    jetbrains.idea
    teams-for-linux
    engrampa
    zotero
    deezer-enhanced
    vlc
    libreoffice-fresh
  ];

  programs = {
    firefox.enable = true;
    keepassxc = {
      enable = true;
      autostart = true;
    };
  };

  xdg.autostart.enable = true;
}
