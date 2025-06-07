{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    gimp-with-plugins
    inkscape-with-extensions
    darktable
    hugin
    audacity
    handbrake
    musescore
    obs-studio

    xcolor

    (pkgs.lazy-app.override {
      pkg = pkgs.scribus;
      desktopItem = pkgs.makeDesktopItem {
        name = "Scribus";
        exec = "scribus %f";
        icon = "scribus";
        desktopName = "Scribus";
        comment = "Page Layout and Publication";
        categories = [ "Qt" "Graphics" "Publishing" ];
        mimeTypes = [
          "application/vnd.scribus"
        ];
      };
    })
  ];

}
