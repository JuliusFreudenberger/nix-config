{
  ...
}: {
  programs.sway = {
    enable = true;
    wrapperFeatures = {
      base = true;
      gtk = true;
    };
  };
  xdg.portal.wlr.enable = true;
}

