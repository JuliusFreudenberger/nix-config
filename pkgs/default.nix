pkgs: rec {
  rofirefox = pkgs.callPackage ./rofirefox {};
  nemo-nextcloud = pkgs.callPackage ./nemo-nextcloud {};
  nemo-engrampa = pkgs.callPackage ./nemo-engrampa {};
  dlrg-fonts = pkgs.callPackage ./dlrg-fonts {};
  i3-scrot = pkgs.callPackage ./i3-scrot {};
}
