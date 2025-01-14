{pkgs, username, ...}: {

  imports = [
    ../../home/core.nix

    ../../home/zsh
    ../../home/neovim
    ../../home/gtk
    ../../home/xdg

    ../../home/direnv
  ];

}
