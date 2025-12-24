{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    jetbrains.idea-ultimate
    jetbrains.pycharm-professional

    vscodium-fhs
    zed-editor.fhs

    k6
  ];

}
