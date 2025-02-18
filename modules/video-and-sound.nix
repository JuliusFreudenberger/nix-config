{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    vlc
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
