{
  pkgs,
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
    xserver.displayManager = {
      lightdm = {
        enable = true;
	greeters.gtk = {
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
