{
  pkgs,
  lib,
  ...
}: {

  environment.systemPackages = with pkgs; [
    distrobox
  ];

}
