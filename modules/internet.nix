{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    transmission_4
    filezilla

    element-desktop
  ];

  programs = {
    firefox.enable = true;
    thunderbird = {
      enable = true;
      package = pkgs.thunderbird-latest;
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

}
