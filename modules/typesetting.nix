{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    typst
    typstyle

    pandoc

    zotero
  ];

}
