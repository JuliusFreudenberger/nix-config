{ inputs, outputs, config, lib, pkgs, ... }:

{
  imports =
    [
      ../../modules/disko/efi-full-btrfs.nix
      ../../modules/systemd-boot.nix

      ../../modules/nix.nix
      ../../modules/network-server.nix
      ../../modules/locale.nix
      ../../modules/server-cli.nix
      ../../modules/sshd.nix
      ../../modules/k3s.nix
      ../../modules/qemu-guest.nix
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];


  networking.hostName = "kube01"; # Define your hostname.

  users = {
    users = {
      julius = {
        initialPassword = "password";
        isNormalUser = true;
        uid = 1000;
        extraGroups = [ "wheel" "julius" ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiZXFM8XFkReb9HuGcY5rtPXsGuZ2eDnBBpI0kcHa6c julius@julius-framework"
        ];
      };
    };
    groups = {
      julius = {
        gid = 1000;
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
