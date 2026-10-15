{config, pkgs, ...}: {
   xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = ["org.gnome.Evince.desktop"];
        "image/svg+xml" = ["eom.desktop"];
        "image/jpeg" = ["eom.desktop"];
        "image/png" = ["eom.desktop"];
        "image/tiff" = ["eom.desktop"];
        "video/quicktime" = ["vlc.desktop"]; # *.mov
        "application/yaml" = ["org.x.editor.desktop"];
        "text/plain" = ["org.x.editor.desktop"];
        "text/calendar" = ["thunderbird.desktop"];
        "application/vnd.oasis.opendocument.text" = ["writer.desktop"];
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = ["writer.desktop"];
      };
    };
    userDirs = {
      enable = true;
      setSessionVariables = false;
    };
  };
}
