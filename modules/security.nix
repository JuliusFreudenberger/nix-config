{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    cryptomator

    keepassxc
  ];

  services.gnome.gnome-keyring.enable = true;

  programs = {
    seahorse.enable = true;
    ausweisapp = {
      enable = true;
      openFirewall = true;
    };
  };

  security = {
    polkit.enable = true;
    soteria.enable = true;
  };

}
