# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ outputs, config, pkgs, ... }:

{
  imports =
    [
      ../../modules/nix.nix
      ../../modules/system.nix
      ../../modules/firmware.nix
      ../../modules/laptop.nix
      ../../modules/network.nix
      ../../modules/locale.nix
      ../../modules/boot-login.nix
      ../../modules/fonts.nix
      ../../modules/cli-essentials.nix
      ../../modules/i3.nix
      ../../modules/fingerprint.nix
      ../../modules/logitech.nix
      ../../modules/connectivity.nix
      ../../modules/video-and-sound.nix
      ../../modules/bluetooth.nix
      ../../modules/desktop-essentials.nix
      ../../modules/internet.nix
      ../../modules/sync-clients.nix
      ../../modules/office.nix
      ../../modules/administration.nix
      ../../modules/creativity.nix
      ../../modules/security.nix
      ../../modules/typesetting.nix
      ../../modules/docker.nix
      ../../modules/distrobox.nix
      ../../modules/gui-coding.nix
      ../../modules/optical-media.nix
      ../../modules/flatpak.nix
      ../../modules/gaming.nix

      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

    nixpkgs = {
      overlays = [
        outputs.overlays.additions
      ];
    };

  # Bootloader.
  boot = {
      loader = {
          efi.canTouchEfiVariables = true;
          systemd-boot = {
	      enable = true;
              editor = false;
          };
      };
      initrd = {
        systemd.enable = true;
        luks.devices = {
          cryptlvm = {
	      device = "/dev/disk/by-uuid/45a8e584-409d-4627-8679-b8cdb837afc4";
	  };
        };
      };
      tmp.useTmpfs = true;
  };

  networking.hostName = "julius-framework"; # Define your hostname.

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

