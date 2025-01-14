{
  pkgs,
  lib,
  ...
}: let
     nemo-with-nextcloud-extensions = pkgs.nemo-with-extensions.override { extensions = [pkgs.nextcloud-client];};
  in {
  environment.systemPackages = with pkgs; [
    sakura
    alacritty

    evince
    zathura
    viewnior
    pavucontrol

    xed-editor
    mate.mate-calc

    xarchiver
    mate.engrampa
    nemo-with-nextcloud-extensions
  ];

  programs = {
    nm-applet.enable = true;
    dconf.enable = true;
  };

}
