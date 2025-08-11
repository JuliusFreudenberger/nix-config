{ inputs, outputs, config, lib, pkgs, ... }:

{
  imports =
    [
      ../../modules/nix.nix
      ../../modules/locale.nix
      ../../modules/server-cli.nix
      ../../modules/sshd.nix
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  # Use the GRUB 2 boot loader.
  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/vda";
    };
    tmp.useTmpfs = true;
  };
  networking.hostName = "nixos-server"; # Define your hostname.
  users = {
    users = {
      julius = {
        isNormalUser = true;
        uid = 1000;
        extraGroups = [ "wheel" "julius" ];
      };
    };
    groups = {
      julius = {
        gid = 1000;
      };
    };
  };

  services.proxmox-ve = {
    enable = true;
    ipAddress = "192.168.122.42";

    # Make vmbr0 bridge visible in Proxmox web interface
    bridges = [ "vmbr0" ];
  };

  # Actually set up the vmbr0 bridge
  networking = {
    bridges.vmbr0.interfaces = [ "enp1s0" ];
    interfaces.vmbr0.useDHCP = lib.mkDefault true;
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
