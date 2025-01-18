{
  pkgs,
  lib,
  ...
}: {
  # Set timezone to null to make it imperatively settable
  time.timeZone = lib.mkForce null;

  services.tzupdate.enable = true;
}
