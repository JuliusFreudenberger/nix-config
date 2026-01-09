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
    neofetch
    tealdeer

    pdfgrep
    pdftk
    p7zip
  ];

  programs = {
    htop.enable = true;
    git.enable = true;
    bat.enable = true;
  };
}
