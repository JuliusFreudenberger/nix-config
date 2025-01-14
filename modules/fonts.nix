{
  pkgs,
  lib,
  ...
}: {
  fonts.packages = with pkgs; [
    noto-fonts
    font-awesome
    terminus_font
    dlrg-fonts
  ];

}
