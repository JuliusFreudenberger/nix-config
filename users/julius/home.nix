{pkgs, username, ...}: {

  imports = [
    ../../home/core.nix

    ../../home/zsh
    ../../home/neovim
    ../../home/gtk
    ../../home/ebook.nix
    ../../home/xdg
    ../../home/sway.nix
    ../../home/kanshi.nix

    ../../home/direnv

    ../../home/gram.nix
  ];

}
