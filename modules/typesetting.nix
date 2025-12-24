{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    typst
    typstyle

    texliveFull

    pandoc

    zotero
  ];

}
