# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ outputs, config, pkgs, ... }:

{
  imports =
    [
      ../../modules/nix.nix
      ../../modules/network-server.nix
      ../../modules/locale.nix
      ../../modules/server-cli.nix
      ../../modules/teleport.nix
      ./teleport-cred.nix

      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

    nixpkgs = {
      overlays = [
        outputs.overlays.additions
      ];
    };

  # Bootloader.
  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  fileSystems."/backups" = 
    { device = "/dev/disk/by-uuid/7ccdab55-fba4-47b8-aef2-74be0103f885";
      fsType = "btrfs";
    };

  networking.hostName = "backup-raspberry"; # Define your hostname.

  users = {
    users = {
      julius = {
        isNormalUser = true;
        uid = 1000;
        extraGroups = [ "wheel" "julius" ];
      };
      restic = {
        isNormalUser = true;
        uid = 1337;
        extraGroups = [ "restic" ];
      };
    };
    groups = {
      julius = { 
        gid = 1000;
      };
      restic = { 
        gid = 1337;
      };
    };
  };

  location = {
    latitude = 48.740556;
    longitude = 9.310833;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}

