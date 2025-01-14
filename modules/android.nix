{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    android-studio-full
    android-tools
    android-udev
  ];

}
