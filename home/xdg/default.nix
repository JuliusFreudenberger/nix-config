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
        "image/tiff" = ["viewnior.desktop"];
        "video/quicktime" = ["vlc.desktop"]; # *.mov
        "application/yaml" = ["org.x.editor.desktop"];
        "text/plain" = ["org.x.editor.desktop"];
        "text/calendar" = ["thunderbird.desktop"];
      };
    };
    userDirs.enable = true;
  };
}
