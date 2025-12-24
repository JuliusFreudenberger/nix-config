{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    jetbrains.idea
    jetbrains.pycharm

    vscodium-fhs
    zed-editor.fhs

    k6
  ];

}
