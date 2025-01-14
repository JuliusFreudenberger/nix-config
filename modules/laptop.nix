{
  pkgs,
  lib,
  ...
}: {

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    lidSwitchDocked = "suspend-then-hibernate";
    powerKey = "ignore";
  };

  programs.auto-cpufreq.enable = true;
  services.tlp.enable = false;
  services.thermald.enable = true;

  virtualisation.docker.enableOnBoot = false;

}
