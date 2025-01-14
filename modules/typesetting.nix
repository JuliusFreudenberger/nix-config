{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    typst
    typst-lsp
    typstfmt

    texliveFull

    pandoc

    zotero
  ];

}
