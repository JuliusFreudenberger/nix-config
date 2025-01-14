{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    jetbrains.idea-ultimate
    jetbrains.pycharm-professional
    jetbrains.phpstorm

    vscodium-fhs
    zed-editor.fhs

    k6
  ];

}
