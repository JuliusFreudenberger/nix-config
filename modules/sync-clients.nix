{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    nextcloud-client
    pcloud
  ];

}
