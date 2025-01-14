{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    #gimp-with-plugins
    inkscape-with-extensions
    darktable
    hugin
    audacity
    handbrake
    musescore
    obs-studio

    xcolor
  ];

}
