{
  pkgs,
  lib,
  ...
}: {
  services.fprintd = {
    enable = true;
 };
}
