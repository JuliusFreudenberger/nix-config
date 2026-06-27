{
  pkgs,
  lib,
  ...
}: {
  services.displayManager.defaultSession = lib.mkDefault "sway";

  programs.sway = {
    enable = true;
    wrapperFeatures = {
      base = true;
      gtk = true;
    };
  };
  xdg.portal = {
    enable = true;
    wlr = {
      enable = true;
      settings = {
        screencast = {
          chooser_type = "dmenu";
          chooser_cmd = "${lib.getExe pkgs.rofi} -dmenu -p 'Select a source to share:'";
        };
      };
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };
}

