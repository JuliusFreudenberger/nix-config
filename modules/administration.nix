{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    remmina

    teleport_16
  ];

}
