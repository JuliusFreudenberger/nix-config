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
      ../../modules/forgejo-actions-runner.nix
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
  networking.hostName = "busch-forgejo-actions-runner"; # Define your hostname.

  services.netbird-client = {
    enable = true;
    managementUrl = "https://netbird.jfreudenberger.de";
    host.setupKey = "5062C655-EC6E-42CF-8263-54C6AD946056";
  };

  services.beszel.agent = {
    enable = true;
    environment = {
      HUB_URL = "https://beszel.jfreudenberger.de";
      DISABLE_SSH = "true";
    };
    environmentFile = config.age.secrets.beszel.path;
  };

  virtualisation.podman.enable = true;

  services.forgejo-runner = {
    instances = {
      runner_own_1 = {
        enable = true;
        secrets = {
          server.connections.default = {
            token_url = config.age.secrets.forgejo-actions-runner-own-1.path;
          };
        };
        settings = {
          server.connections.default = {
            url = "https://git.jfreudenberger.de";
            uuid = "0fbf38af-fd38-46b2-afe1-8feecbf0c705";
          };
          runner.labels = [
            "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-24.04@sha256:5d6a17640b25694988b9db5a4145537b9918e5430116b2cf90d84e837609b382"
            "debian:docker://docker.io/library/node:lts@sha256:5711a0d445a1af54af9589066c646df387d1831a608226f4cd694fc59e745059"
            "nix-stable:docker://nixos/nix:2.35.1@sha256:377d4887aca98f0dfa12971c1ea6d6a625a435d8b610d4c95a436843da6fbfd1"
          ];
        };
      };
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
