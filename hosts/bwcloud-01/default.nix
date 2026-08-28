{ inputs, outputs, config, lib, pkgs, ... }:

{
  imports =
    [
      ./secrets.nix

      ../../users/julius/nixos-server.nix
      ../../users/nixremote.nix
      ../../modules/nix.nix
      ../../modules/network-server.nix
      ../../modules/locale.nix
      ../../modules/server-cli.nix
      ../../modules/sshd.nix
      ../../modules/qemu-guest.nix
      ../../modules/docker.nix
      ../../modules/auto-upgrade.nix
      "${inputs.secrets}/modules/opkssh.nix"

      ../../modules/traefik.nix
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  services.traefik-docker = {
    enable = true;
    dashboardUrl = "dashboard.juliusfr.eu";
    dnsChallengeProvider = "netcup";
    dnsSecrets = [
      config.age.secrets.netcup-dns
    ];
  };

  # Disable classic networking configuration
  networking.useDHCP = lib.mkForce false;

  networking.hostName = "nixos"; # Define your hostname.

  boot = {
    tmp.cleanOnBoot = true;
    growPartition = true;
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "console=ttyS0" ];
    loader = {
      grub.enable = true;
      efi.canTouchEfiVariables = true;
      grub.device = lib.mkDefault "/dev/vda";
    };
  };

  networking = {
    dhcpcd.enable = false;
    wireless.enable = false;
  };

  systemd.network.enable = true;

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
      options = [ "nofail" "x-systemd.device-timeout=5s" ];
    };
    "/" = {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };
  };


  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}
