{
  pkgs,
  lib,
  ...
}: {
  networking = {
    networkmanager = {
      enable = true;
      wifi.powersave = true;
      # logLevel = "INFO";
    };
    wireguard.enable = true;
    firewall = {
      # if packets are still dropped, they will show up in dmesg
      logReversePathDrops = true;
      checkReversePath = "loose";
    };
  };
}
