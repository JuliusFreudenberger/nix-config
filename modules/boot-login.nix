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
        enable = false;
        greeters.gtk.enable = false;
        greeters.gtk-custom = {
          enable = false;
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

  services.greetd = {
    enable = true;
    settings = {
      skip_selection = true;
    };
  };

  programs.regreet = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
    };
    iconTheme = {
      name = "Arc";
      package = pkgs.arc-icon-theme;
    };
  };

}
