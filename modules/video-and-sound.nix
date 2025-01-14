{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    #shotcut
  ];

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs = {
    droidcam.enable = true;
  };
}
