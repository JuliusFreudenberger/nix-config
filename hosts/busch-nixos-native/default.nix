{ inputs, outputs, config, lib, pkgs, ... }:

{
  imports =
    [
      ../../modules/disko/legacy-full-ext4.nix
      ./secrets.nix

      ../../users/julius/nixos-server.nix
      ../../modules/nix.nix
      ../../modules/auto-upgrade.nix
      ../../modules/qemu-guest.nix
      ../../modules/locale.nix
      ../../modules/server-cli.nix
      ../../modules/sshd.nix
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
  networking.hostName = "busch-nixos-native"; # Define your hostname.

  services.netbird-client = {
    enable = true;
    managementUrl = "https://netbird.jfreudenberger.de";
    host.setupKey = "E182754A-F338-4DAE-8036-03404033D30E";
  };

  services.beszel.agent = {
    enable = true;
    environment = {
      HUB_URL = "https://beszel.jfreudenberger.de";
      DISABLE_SSH = "true";
    };
    environmentFile = config.age.secrets.beszel.path;
  };

  services.renovate = {
    enable = true;
    schedule = "*:0/10";
    credentials = {
      RENOVATE_TOKEN = config.age.secrets.renovate-token.path;
      RENOVATE_GITHUB_COM_TOKEN = config.age.secrets.renovate-github-com-token.path;
    };
    settings = {
      autodiscover = true;
      gitAuthor = "Renovate Bot <renovate@jfreudenberger.de>";
      platform = "forgejo";
      endpoint = "https://git.jfreudenberger.de";
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
