{
  pkgs,
  lib,
  config,
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
  ] ++ lib.optionals config.virtualisation.docker.enable [ docker-credential-helpers ];

  programs = {
    htop.enable = true;
    zsh.enable = true;
  };
}
