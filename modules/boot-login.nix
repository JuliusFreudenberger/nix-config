{
  pkgs,
  lib,
  ...
}: {
  boot = {
    initrd.systemd.enable = true;
    kernelParams = ["quiet"];
    plymouth = {
      enable = true;
      theme = "bgrt";
    };
  };

  services = {
    displayManager.defaultSession = "sway";
    xserver.displayManager = {
      lightdm = {
        enable = true;
        greeters.gtk.enable = false;
        greeters.gtk-custom = {
          enable = true;
          theme = {
            name = "Adwaita-dark";
          };
          iconTheme = {
            name = "Arc";
            package = pkgs.arc-icon-theme;
          };
        };
      };
    };
  };

}
