{ inputs, outputs, config, lib, pkgs, ... }:

{
  imports =
    [
      ./secrets.nix

      ../../modules/disko/legacy-full-ext4-swap.nix

      ../../users/julius/nixos-server.nix
      ../../modules/nix.nix
      ../../modules/locale.nix
      ../../modules/server-cli.nix
      ../../modules/sshd.nix
      ../../modules/qemu-guest.nix
      ../../modules/docker.nix
      ../../modules/traefik.nix
      ../../modules/pocket-id.nix
      ../../modules/netbird-docker.nix
      ../../modules/auto-upgrade.nix
      "${inputs.secrets}/modules/opkssh.nix"
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  #services.openssh.openFirewall = false;

  services = {
    traefik-docker = {
      enable = true;
      dashboardUrl = "traefik.netbird.jfreudenberger.de";
      dnsChallengeProvider = "inwx";
      dnsSecrets = [
        config.age.secrets.inwx
      ];
    };

    pocket-id-docker.enable = true;
    pocket-id = {
      settings = {
        APP_URL = "https://login.jfreudenberger.de";
        TRUST_PROXY = true;
      };
      environmentFile = config.age.secrets.pocket-id.path;
    };

    netbird-docker = {
      enable = true;
      secrets = config.age.secrets.netbird-server;
      proxy = {
        domain = "netbird.jfreudenberger.de";
        token-secret = config.age.secrets.netbird-proxy;
      };
    };
    netbird.server = let
      domain = "netbird.jfreudenberger.de";
    in {
      domain = domain;
      management.domain = domain;
      dashboard.domain = domain;
      signal.domain = domain;
    };
  };

  systemd.network = {
    enable = true;
      networks."10-wan" = {
      matchConfig.Name = "enp1s0";
      networkConfig.DHCP = "no";
      address = [
        "46.224.47.24/32"
        "2a01:4f8:c013:bf68::1/64"
      ];
      routes = [
        { Gateway = "172.31.1.1"; GatewayOnLink = true; }
        { Gateway = "fe80::1"; GatewayOnLink = true; }
      ];
      dns = [ "9.9.9.9" ];
    };
  };

  boot = {
    tmp.cleanOnBoot = true;
    growPartition = true;
    kernelParams = [ "console=ttyS0" ];
    loader = {
      grub.enable = true;
    };
  };

  # Disable classic networking configuration
  networking.useDHCP = lib.mkForce false;

  networking.hostName = "srv03"; # Define your hostname.

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
