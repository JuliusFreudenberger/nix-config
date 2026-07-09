{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: let
  modifier = "Mod4";
  cfg = config.wayland.windowManager.sway;
  background = "${pkgs.nixos-artwork.wallpapers.simple-dark-gray-bottom}/share/wallpapers/simple-dark-gray/contents/images/nix-wallpaper-simple-dark-gray_bottom.png";

  applications = "(D)iscord, Slac(k), (E)lement, (N)extcloud, (M)usic, (B)luetooth, (V)alent";
  exit = "(l)ock, (e)xit, switch_(u)ser, (s)uspend, (h)ibernate, (r)eboot, (Shift+s)hutdown";

  sinkToggle = "${pkgs.alsa-utils}/bin/amixer -q set Master toggle";
  sourceToggle = "${pkgs.alsa-utils}/bin/amixer -q set Capture toggle";
in {
  home.packages = with pkgs; [
    wdisplays
    rofi
    ydotool
  ];

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures = {
      base = true;
      gtk = true;
    };
    systemd.dbusImplementation = osConfig.services.dbus.implementation;
    config = {
      modifier = modifier;
      terminal = lib.getExe pkgs.sakura;
      menu = "${lib.getExe pkgs.rofi} -show drun";
      defaultWorkspace = "workspace number 1";
      fonts = {
        names = [ "FontAwesome5Free" "xft:URWGothic-Book" ];
        size = 11.0;
      };
      input = {
        "*" = {
          xkb_layout = "eu";
        };
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
        };
      };
      output = {
        "*" = {
          bg = "${background} fill";
        };
        eDP-1 = {
          scale = "1";
        };
      };
      startup = [
        { command = (lib.getExe pkgs.dunst); }
        { command = (lib.getExe pkgs.networkmanagerapplet); }
        { command = "${lib.getExe pkgs.solaar} -w hide"; }
        { command = "${pkgs.ydotool}/bin/ydotoold"; }
      ];
      keybindings = lib.mkOptionDefault {
        "${modifier}+Ctrl+${cfg.config.left}" = "move workspace to output left";
        "${modifier}+Ctrl+${cfg.config.down}" = "move workspace to output down";
        "${modifier}+Ctrl+${cfg.config.up}" = "move workspace to output up";
        "${modifier}+Ctrl+${cfg.config.right}" = "move workspace to output right";
        "${modifier}+Ctrl+1" = "move container to workspace number 1; workspace number 1";
        "${modifier}+Ctrl+2" = "move container to workspace number 2; workspace number 2";
        "${modifier}+Ctrl+3" = "move container to workspace number 3; workspace number 3";
        "${modifier}+Ctrl+4" = "move container to workspace number 4; workspace number 4";
        "${modifier}+Ctrl+5" = "move container to workspace number 5; workspace number 5";
        "${modifier}+Ctrl+6" = "move container to workspace number 6; workspace number 6";
        "${modifier}+Ctrl+7" = "move container to workspace number 7; workspace number 7";
        "${modifier}+Ctrl+8" = "move container to workspace number 8; workspace number 8";
        "${modifier}+Ctrl+9" = "move container to workspace number 9; workspace number 9";
        "${modifier}+Ctrl+0" = "move container to workspace number 10; workspace number 10";
        "${modifier}+Shift+p" = "exec rofi-rbw --action copy";
        "XF86MonBrightnessUp" = "exec ${lib.getExe pkgs.brightnessctl} s +10%";
        "${modifier}+Tab" = "exec ${lib.getExe pkgs.rofi} -show window";
        "XF86MonBrightnessDown" = "exec ${lib.getExe pkgs.brightnessctl} s 10%-";
        "XF86AudioRaiseVolume" = "exec ${pkgs.alsa-utils}/bin/amixer -q set Master 5%+ unmute";
        "XF86AudioLowerVolume" = "exec ${pkgs.alsa-utils}/bin/amixer -q set Master 5%- unmute";
        "XF86AudioMute" = "exec ${sinkToggle}";
        "XF86AudioMicMute" = "exec ${sourceToggle}";
        "${modifier}+c" = "exec ${sourceToggle}";
        "XF86AudioPlay" = "exec ${lib.getExe pkgs.playerctl} play-pause";
        "${modifier}+ctrl+space" = "exec ${lib.getExe pkgs.playerctl} play-pause";
        "${modifier}+z" = "exec ${lib.getExe pkgs.playerctl} volume 5-";
        "${modifier}+a" = "exec ${lib.getExe pkgs.playerctl} volume 5+";
        "XF86AudioNext" = "exec ${lib.getExe pkgs.playerctl} next";
        "XF86AudioPrev" = "exec ${lib.getExe pkgs.playerctl} previous";
        "${modifier}+F2" = "exec ${lib.getExe pkgs.firefox}";
        "${modifier}+Ctrl+F2" = "exec ${lib.getExe pkgs.rofirefox}";
        "${modifier}+Shift+F2" = "exec ${lib.getExe pkgs.firefox} --private-window";
        "${modifier}+F3" = "exec nemo";
        "${modifier}+F4" = "exec ${lib.getExe pkgs.thunderbird}";
        "${modifier}+Ctrl+w" = "exec ${lib.getExe pkgs.networkmanager_dmenu}";
        "${modifier}+Shift+d" = ''mode "${applications}"'';
        "${modifier}+Escape" = ''mode "${exit}"'';
      };
      modes = {
        resize = {
          "${cfg.config.left}" = "resize shrink width 10 px";
          "${cfg.config.down}" = "resize grow height 10 px";
          "${cfg.config.up}" = "resize shrink height 10 px";
          "${cfg.config.right}" = "resize grow width 10 px";
          "Left" = "resize shrink width 10 px";
          "Down" = "resize grow height 10 px";
          "Up" = "resize shrink height 10 px";
          "Right" = "resize grow width 10 px";
          "Escape" = "mode default";
          "Return" = "mode default";
        };
        "${applications}" = {
          "d" = "exec flatpak run com.discordapp.Discord";
          "k" = "exec flatpak run com.slack.Slack";
          "e" = "exec element-desktop --password-store=gnome-libsecret";
          "Shift+e" = "exec element-desktop --password-store=gnome-libsecret --profile=JuliusFreudenberger";
          "n" = "exec nextcloud";
          "m" = "exec flatpak run com.spotify.Client";
          "b" = "exec blueman";
          "v" = "exec valent";
          "Escape" = "mode default";
          "Return" = "mode default";
        };
        "${exit}" = {
          "l" = "exec ${pkgs.systemd}/bin/loginctl lock-session, mode default";
          "s" = "exec ${pkgs.systemd}/bin/systemctl suspend, mode default";
          "u" = "exec ${pkgs.lightdm}/bin/dm-tool lock, mode default";
          "e" = "exec ${pkgs.sway}/bin/swaymsg exit, mode default";
          "h" = "exec ${pkgs.systemd}/bin/systemctl hibernate, mode default";
          "r" = "exec ${pkgs.systemd}/bin/systemctl reboot, mode default";
          "Shift+s" = "exec ${pkgs.systemd}/bin/systemctl poweroff, mode default";
          "Escape" = "mode default";
          "Return" = "mode default";
        };
      };
      assigns = {
        "6" = [{ app_id = "thunderbird"; }];
        "5" = [{ app_id = "^element$|^com.slack.Slack$"; }];
      };
      floating.criteria = [
        { title = "MuseScore: Play Panel"; }
        { app_id = "org.pulseaudio.pavucontrol"; }
        { app_id = "system-config-printer";}
        { app_id = "mate-calc"; }
        { app_id = ".blueman-manager-wrapped"; }
        { app_id = "nm-connection-editor"; }
        { app_id = "Zotero"; window_role = "Toplevel"; }
        { app_id = "com.nextcloud.desktopclient.nextcloud"; }
      ];
      colors = {
        background = "#2B2C2B";
        focused = {
          background = "#556064";
          border = "#556064";
          childBorder = "#556064";
          text = "#80FFF9";
          indicator = "#FDF6E3";
        };
        focusedInactive = {
          background = "#2F3D44";
          border = "#2F3D44";
          childBorder = "#2F3D44";
          text = "#1ABC9C";
          indicator = "#454948";
        };
        unfocused = {
          background = "#2F3D44";
          border = "#2F3D44";
          childBorder = "#2F3D44";
          text = "#1ABC9C";
          indicator = "#454948";
        };
        urgent = {
          background = "#FDF6E3";
          border = "#CB4B16";
          childBorder = "#CB4B16";
          text = "#1ABC9C";
          indicator = "#268BD2";
        };
        placeholder = {
          background = "#0c0c0c";
          border = "#000000";
          childBorder = "#000000";
          text = "#ffffff";
          indicator = "#000000";
        };
      };
      bars = [];
    };
    extraConfig = ''
      assign [class = "^discord$"] 5
      focus_wrapping yes
    '';
  };

  programs.swaylock = {
    enable = true;
    settings = {
      image = background;
    };
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "bottom";
        height = 30;
        output = [ "*" ];
        modules-left = [
          "sway/workspaces"
          "sway/mode"
        ];
        modules-right = [
          "pulseaudio#sink"
          "pulseaudio#source"
          "network"
          "memory"
          "cpu"
          "backlight"
          "battery"
          "mpris"
          "clock"
          "tray"
        ];
        "tray" = {
          "spacing" = 10;
        };
        "pulseaudio#sink" = {
          "format" = " {volume}%";
          "format-muted" = " MUTE";
          "scroll-step" = 5;
          "on-right-click" = sinkToggle;
        };
        "pulseaudio#source" = {
          "format" = "{format_source}";
          "format-source" = " {volume}%";
          "format-source-muted" = " MUTE";
          "tooltip-format" = "{source_desc}";
          "scroll-step" = 5;
          "target" = "source";
          "on-right-click" = sourceToggle;
        };
        "network" = {
          "interface" = "wl*";
          "format" = " {signalStrength}% {essid}";
          "format-disconnected" = "";
        };
        "memory" = {
          "format" = " {used:0.1f}G/{total:0.1f}G ({percentage}%)";
        };
        "cpu" = {
          "format" = " {usage}%";
        };
        "mpris" = {
          "format" = "{status_icon} {dynamic}";
          "ignored-players" = "firefox";
          "status-icons" = {
            "playing" = "";
            "paused" = "";
            "stopped" = "";
          };
        };
        "clock" = {
          "interval" = 1;
          "format" = " {:%d.%m.%Y %H:%M:%S}";
          "tooltip-format" = "<tt><small>{calendar}</small></tt>";
        };
        "battery" = {
          "format" = "⚡ {icon} {capacity}% ({time})";
          "format-plugged" = "";
          "format-icons" = {
            "default" = ["DIS"];
            "charging" = ["CHR"];
          };
          "format-time" = "{H:02d}:{M:02d}";
        };
        "backlight" = {
          "format" = "{icon} {percent}%";
          "format-icons" = [" "];
          "scroll-step" = 5;
        };
      };
    };
    style = ''
    * {
        font-family: "UbuntuMono Nerd Font";
        font-size: 14px;
    }

    window#waybar {
        background-color: #222d31;
        color: #f9faf9;
    }

    .modules-left {
        background-color: #222d31;
        padding: 0px 0px 0px 0px;
    }

    .modules-right {
        background-color: #222d31;
        padding: 0px 5px 0px 0px;
    }

    #custom-scratch {
        background-color: #222d31;
        color: #b8b8b8;
        padding: 0px 9px 0px 9px;
    }

    #workspaces button {
        padding: 0px 8px 0px 8px;
        min-width: 1px;
        color: #fdf6e3;
        background-color: #353836;
        border-radius: 0;
        border-color: #595b5b;
    }

    #workspaces button.focused {
        background-color: #16a085;
        color: #292f34;
        border-color: #fdf6e3;
    }

    #mode {
        background-color: #2c2c2c;
        color: #f9faf9;
        padding: 0px 5px 0px 5px;
        border: 1px solid #16a085;
    }

    #window {
        color: #ffffff;
        background-color: #285577;
        padding: 0px 10px 0px 10px;
    }

    window#waybar.empty #window {
        background-color: transparent;
        color: transparent;
    }

    window#waybar.empty {
        background-color: #323232;
    }

    #network,
    #temperature,
    #backlight,
    #pulseaudio,
    #battery,
    #cpu,
    #memory {
        padding: 0px 10px 0px 10px;
    }

    #clock {
        margin: 0px 10px 0px 10px;
    }

    #tray {
        padding: 0px 0px 0px 0px;
        margin: 0px 0px 0px 0px;
    }

    #battery.critical {
        color: #ff5555;
    }

    #cpu.high {
        color: #fffc00;
    }

    #cpu.intensive {
        color: #ff0000;
    }

    #pulseaudio.sink.muted {
        color: #ff0000;
    }
    #pulseaudio.source.source-muted {
        color: #ff0000;
    }
'';
  };

  services.swayidle = let
      dimDuration = 15;
      dimScreen = "${lib.getExe pkgs.chayang} -d ${toString dimDuration}";
      swaylock = "${lib.getExe pkgs.swaylock} -f";
      switchOutput = "${pkgs.sway}/bin/swaymsg 'output * power'";
    in {
      enable = true;
      events = {
        before-sleep = swaylock;
        lock = swaylock;
        after-resume = "${switchOutput} on";
      };
      timeouts = [
        { timeout = 300; command = "${dimScreen} && ${switchOutput} off && ${swaylock}"; resumeCommand = "${switchOutput} on"; }
      ];
    };

  services.wlsunset = {
    enable = true;
    latitude = osConfig.location.latitude;
    longitude = osConfig.location.longitude;
  };
}
