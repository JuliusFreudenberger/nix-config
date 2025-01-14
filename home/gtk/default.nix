{config, pkgs, ...}: {
  gtk = {
    enable = true;
    theme.name = "Adwaita-dark";
    iconTheme = {
      name = "Arc";
      package = pkgs.arc-icon-theme;
    };
  };
}
