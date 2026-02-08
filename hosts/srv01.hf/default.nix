{ inputs, outputs, config, lib, pkgs, ... }:

{
  imports =
    [
      ../../modules/disko/efi-full-btrfs.nix
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
      ../../modules/teleport.nix
      ../../modules/portainer_agent.nix
      ../../modules/pangolin.nix
      ../../modules/newt.nix
      ../../modules/dockhand.nix
      ../../modules/auto-upgrade.nix
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  services.openssh.openFirewall = false;
  services.teleport = {
    enable = true;
    settings.teleport = {
      ca_pin = config.age.secrets."teleport-ca_pin".path;
      auth_token = config.age.secrets."teleport-join_token".path;
    };
  };

  virtualisation.oci-containers.containers.portainer_agent.environmentFiles = [ config.age.secrets."portainer-join_token".path ];

  services = {
    pangolin = {
      dnsProvider = "netcup";
      baseDomain = "juliusfr.eu";
      letsEncryptEmail = "contact@jfreudenberger.de";
      environmentFile = config.age.secrets."pangolin".path;
    };
    traefik = {
      environmentFiles = [ config.age.secrets."netcup-dns".path ];
    };
  };

  services.newt-docker = {
    enable = true;
    pangolinEndpoint = "https://pangolin.juliusfr.eu";
    connectionSecret = config.age.secrets."newt";
  };

  services.dockhand = {
    enable = true;
    appUrl = "dockhand.juliusfr.eu";
  };

  systemd.network = {
    enable = true;
      networks."10-wan" = {
      matchConfig.Name = "ens18";
      networkConfig.DHCP = "no";
      address = [
        "77.90.17.93/24"
        "2a06:de00:100:63::2/64"
      ];
      routes = [
        { Gateway = "77.90.17.1"; }
        { Gateway = "2a06:de00:100::1"; GatewayOnLink = true; }
      ];
      dns = [ "9.9.9.9" ];
    };
  };

  # Disable classic networking configuration
  networking.useDHCP = lib.mkForce false;

  networking.hostName = "srv01-hf"; # Define your hostname.

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
