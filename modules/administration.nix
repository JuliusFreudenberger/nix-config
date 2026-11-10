{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    remmina
    gparted

    teleport_17.client
    opkssh
  ];

}
