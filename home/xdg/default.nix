{config, pkgs, ...}: {
   xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = ["org.gnome.Evince.desktop"];
        "image/svg+xml" = ["viewnior.desktop"];
        "image/jpeg" = ["viewnior.desktop"];
        "image/png" = ["viewnior.desktop"];
        "application/yaml" = ["org.x.editor.desktop"];
        "text/plain" = ["org.x.editor.desktop"];
      };
    };
    userDirs.enable = true;
  };
}
