{pkgs, ...}: {
  # i3 related options
  environment.pathsToLink = ["/libexec"]; # links /libexec from derivations to /run/current-system/sw
  services.displayManager.defaultSession = "none+i3";
  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        rofi # application launcher, the same as dmenu
        dunst # notification daemon
        i3blocks # status bar
	lightlocker
        xautolock # lock screen after some time
        i3status # provide information to i3bar
        i3-gaps # i3 with gaps
        nitrogen # set wallpaper
        acpi # battery information
        arandr # screen layout manager
	alsa-utils
        dex # autostart applications
        xbindkeys # bind keys to commands
        xclip
        xorg.xbacklight # control screen brightness
	brightnessctl
        numlockx
        xorg.xdpyinfo # get screen information
        sysstat # get system information

	scrot
        i3-scrot
	rofirefox
	rofi-rbw
	rbw
	pinentry-gnome3
	xdotool
	playerctl
      ];
    };

    # Configure keymap in X11
    xkb.layout = "eu";
    xkb.variant = "";
  };

  services = {
    libinput.touchpad.naturalScrolling = true;
    gvfs.enable = true; # Mount, trash, and other functionalities
    udisks2.enable = true;
    autorandr.enable = true;
    redshift.enable = true;
  };
}
