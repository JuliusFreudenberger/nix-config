{config, pkgs, ...}: {
  gtk = {
    enable = true;
    colorScheme = "dark";
    theme.name = "Adwaita-dark";
    iconTheme = {
      name = "Arc";
      package = pkgs.arc-icon-theme;
    };
    gtk4.theme = null;
  };
}
