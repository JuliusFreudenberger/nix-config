{
  pkgs,
  lib,
  config,
  ...
}: {
  home.packages = with pkgs; [
    maven
    gradle
  ];

  home.extraDependencies = with pkgs; [
    jdk11
    jdk17
    jdk21
  ];
}
