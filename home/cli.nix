{
  pkgs,
  lib,
  config,
  ...
}: {
  home.packages = with pkgs; [
    wget
    curl
    git
    fastfetch
    tealdeer

    pdfgrep
    pdftk
    p7zip
  ];

  programs = {
    htop.enable = true;
    bat.enable = true;
  };
}
