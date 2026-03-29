{
  pkgs,
  lib,
  config,
  ...
}: {
  users.users.julius = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" "kvm" ];
    shell = pkgs.zsh;
  };

  nix.settings.trusted-users = [ "julius" ];
}
