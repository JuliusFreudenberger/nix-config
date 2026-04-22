{
  pkgs,
  lib,
  ...
}: {

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  services.logind.settings.Login = {
    HandleLidSwitch= "suspend-then-hibernate";
    HandleLidSwitchDocked = "suspend-then-hibernate";
    HandlePowerKey = "ignore";
  };

  programs.auto-cpufreq.enable = true;
  services.tlp.enable = false;
  services.thermald.enable = true;

  virtualisation.docker.enableOnBoot = false;

}
