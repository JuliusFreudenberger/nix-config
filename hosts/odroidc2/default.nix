# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, outputs, config, pkgs, ... }:

{
  imports =
    [
      ./secrets.nix

      ../../users/julius/nixos-server.nix
      ../../modules/nix.nix
      ../../modules/locale.nix
      ../../modules/server-cli.nix
      ../../modules/sshd.nix
      ../../modules/docker.nix
      ../../modules/hawser.nix
      ../../modules/netbird-client.nix
      #../../modules/auto-upgrade.nix
      "${inputs.secrets}/modules/opkssh.nix"
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  services.netbird-client = {
    enable = true;
    managementUrl = "https://netbird.jfreudenberger.de";
    host.setupKey = "921CEE27-22C3-4457-A583-42BBCA72B998";
  };

  services.hawser = {
    enable = true;
    dockhandServerUrl = "wss://dockhand-connect.jfreudenberger.de/api/hawser/connect";
    tokenSecretFile = config.age.secrets.hawser-token;
  };

  services.beszel.agent = {
    enable = true;
    environment = {
      HUB_URL = "https://beszel.jfreudenberger.de";
      DISABLE_SSH = "true";
    };
    environmentFile = config.age.secrets.beszel.path;
  };

  networking.firewall = {
    allowedTCPPorts = [
      # Home assistant
      8123
    ];
  };

  networking.hostName = "odroidc2"; # Define your hostname.

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}

