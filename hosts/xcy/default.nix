{ inputs, outputs, config, lib, pkgs, pkgs-unstable, ... }:

{
  imports =
    [
      ./secrets.nix
      ./disko.nix

      ../../users/julius/nixos-server.nix
      ../../modules/nix.nix
      ../../modules/locale.nix
      ../../modules/server-cli.nix
      ../../modules/sshd.nix
      ../../modules/docker.nix
      ../../modules/hawser.nix
      ../../modules/netbird-client.nix
      ../../modules/auto-upgrade.nix
      "${inputs.secrets}/modules/opkssh.nix"
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  services.netbird-client = {
    enable = true;
    managementUrl = "https://netbird.jfreudenberger.de";
    host.setupKey = "86D1861F-193B-44F5-9B03-1E34C126FA6F";
    docker.setupKey = "A9715FB6-8BF2-4274-BE02-43740A3BD4D9";
  };

  services.hawser = {
    enable = true;
    dockhandServerUrl = "wss://dockhand-connect.jfreudenberger.de/api/hawser/connect";
    tokenSecretFile = config.age.secrets.hawser-token;
  };

  networking.firewall = {
    checkReversePath = "loose";
    allowedTCPPorts = [
      # Ports for Unifi Server
      11443
      5005
      9543
      6789
      8080
      8443
      8444
      11084
      5671
      8880
      8881
      8882

      # Home assistant
      8123
    ];
    allowedUDPPorts = [
      # Unifi Server
      3478
      5514
      10003
    ];
  };


  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  boot = {
    tmp.cleanOnBoot = true;
    tmp.useTmpfs = true;
    growPartition = true;
    initrd.systemd.enable = true;
    loader = {
      efi.canTouchEfiVariables = true;
      grub.enable = false;
      systemd-boot.enable = false;
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      extraEfiSysMountPoints = [
        "/boot-fallback"
      ];
    };
  };

  networking.hostName = "xcy"; # Define your hostname.

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
