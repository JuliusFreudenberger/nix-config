{ inputs, outputs, config, lib, pkgs, ... }:

{
  imports =
    [
      ../../modules/disko/legacy-full-ext4.nix
      ./secrets.nix

      ../../users/julius/nixos-server.nix
      ../../modules/nix.nix
      ../../modules/auto-upgrade.nix
      ../../modules/locale.nix
      ../../modules/server-cli.nix
      ../../modules/sshd.nix
      ../../modules/docker.nix
      ../../modules/hawser.nix
      ../../modules/netbird-client.nix
      "${inputs.secrets}/modules/opkssh.nix"

      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot = {
    loader.grub = {
      enable = true;
    };
    tmp.useTmpfs = true;
  };

  hardware = {
    graphics.enable = true;
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
      # TODO GTX 970 or GTX 960 driver 580 (>= 545)
    };
    nvidia-container-toolkit.enable = true;
  };
  nixpkgs.config.nvidia.acceptLicense = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  networking.hostName = "busch-gpu-docker"; # Define your hostname.

  services.netbird-client = {
    enable = true;
    managementUrl = "https://netbird.jfreudenberger.de";
    host.setupKey = "830217A8-BE0A-4919-A262-3CF7599487BA";
    docker.setupKey = "C4C9FAE3-5FAE-4949-B8E8-BEDA3B954859";
    dockerSubnet = "40";
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
