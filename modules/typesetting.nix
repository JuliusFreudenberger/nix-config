{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    typst
    typstfmt

    texliveFull

    pandoc

    zotero
  ];

}
