{
  pkgs,
  ...
}: {
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
          chooser_type = "simple";
          chooser_cmd = "${pkgs.slurp}/bin/slurp -f 'Select: %o' -or";
        };
      };
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };
}

