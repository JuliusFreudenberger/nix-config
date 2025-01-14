pkgs: rec {
  rofirefox = pkgs.callPackage ./rofirefox {};
  nemo-nextcloud = pkgs.callPackage ./nemo-nextcloud {};
  dlrg-fonts = pkgs.callPackage ./dlrg-fonts {};
  i3-scrot = pkgs.callPackage ./i3-scrot {};
}
