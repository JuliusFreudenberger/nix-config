{
  pkgs,
  lib,
  config,
  ...
}: {
  users.users.julius = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker"];
    shell = pkgs.zsh;
  };
}
