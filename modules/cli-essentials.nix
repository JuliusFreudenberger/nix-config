{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    neofetch
    bat
    tealdeer

    pdfgrep
    pdftk
    p7zip
  ];

  programs = {
    htop.enable = true;
    zsh.enable = true;
  };
}
