{
  pkgs,
  lib,
  config,
  ...
}: {
  home.packages = with pkgs; [
    jetbrains.idea
    teams-for-linux
    mate.engrampa
    zotero
    deezer-enhanced
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
