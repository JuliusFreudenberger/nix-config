{
  pkgs,
  lib,
  ...
}: let
     nemo-with-nextcloud-extensions = pkgs.nemo-with-extensions.override { extensions = [ pkgs.nextcloud-client pkgs.nemo-engrampa ];};
  in {
  environment.systemPackages = with pkgs; [
    sakura
    alacritty

    evince
    zathura
    viewnior
    pavucontrol

    xed-editor
    mate-calc

    xarchiver
    engrampa
    nemo-with-nextcloud-extensions
  ];

  programs = {
    nm-applet.enable = true;
    dconf.enable = true;
  };

}
