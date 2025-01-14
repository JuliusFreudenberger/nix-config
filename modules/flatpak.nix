{
  pkgs,
  lib,
  ...
}: {

  services = {
    flatpak.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    config = {
      common = {
        default = ["gtk"];
      };
    };
    xdgOpenUsePortal = true;
  };

}
