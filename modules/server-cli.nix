{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    wget
    curl
    git

    btrfs-progs
  ];

  programs = {
    htop.enable = true;
    vim.enable = true;
  };
}
