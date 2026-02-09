{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: let
  modifier = "Mod4";
  cfg = config.wayland.windowManager.sway;

  applications = "(D)iscord, Slac(k), (E)lement, (N)extcloud, (M)usic, (B)luetooth, (V)alent";
  i3exit = "(l)ock, (e)xit, switch_(u)ser, (s)uspend, (h)ibernate, (r)eboot, (Shift+s)hutdown";
  i3exitProgram = "/home/julius/.config/i3/i3exit";
in {
  home.packages = with pkgs; [
    wdisplays
    rofi
    ydotool
  ];

  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = modifier;
      terminal = lib.getExe pkgs.sakura;
      menu = "${lib.getExe pkgs.rofi} -show drun";
      # rename workspaces
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
          bg = "${pkgs.nixos-artwork.wallpapers.simple-dark-gray-bottom}/share/wallpapers/simple-dark-gray-2018-08-28/contents/images/nix-wallpaper-simple-dark-gray_bottom.png fill";
        };
        eDP-1 = {
          scale = "1";
        };
      };
      startup = [
        { command = (lib.getExe pkgs.dunst); }
        { command = (lib.getExe pkgs.networkmanagerapplet); }
        { command = (lib.getExe pkgs.solaar); }
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
        "XF86AudioMute" = "exec ${pkgs.alsa-utils}/bin/amixer -q set Master toggle";
        "XF86AudioMicMute" = "exec ${pkgs.alsa-utils}/bin/amixer -q set Capture toggle";
        "${modifier}+c" = "exec ${pkgs.alsa-utils}/bin/amixer -q set Capture toggle";
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
        "${modifier}+Shift+d" = ''mode "${applications}"'';
        "${modifier}+Escape" = ''mode "${i3exit}"'';
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
        "${i3exit}" = {
          "l" = "exec ${i3exitProgram} lock, mode default";
          "Shift+l" = "exec ${i3exitProgram} slock, mode default";
          "s" = "exec ${i3exitProgram} suspend, mode default";
          "u" = "exec ${i3exitProgram} switch_user, mode default";
          "e" = "exec ${i3exitProgram} logout, mode default";
          "h" = "exec ${i3exitProgram} hibernate, mode default";
          "r" = "exec ${i3exitProgram} reboot, mode default";
          "Shift+s" = "exec ${i3exitProgram} shutdown, mode default";
          "Escape" = "mode default";
          "Return" = "mode default";
        };
      };
      assigns = {
        "6" = [{ app_id = "thunderbird"; }];
        "5" = [{ app_id = "^Element$|^com.slack.Slack$"; }];
      };
      floating.criteria = [
        { title = "MuseScore: Play Panel"; }
        { class = "pavucontrol"; }
        { class = "System-config-printer.py";}
        { class = "Mate-calc"; }
        { class = "Blueman-manager"; }
        { class = "Nm-connection-editor"; }
        { class = "Zotero"; window_role = "Toplevel"; }
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
      bars = [
        {
          mode = "dock";
          hiddenState = "hide";
          position = "bottom";
          workspaceButtons = true;
          workspaceNumbers = true;
          statusCommand = "${lib.getExe pkgs.i3blocks} -c ~/.config/i3/i3blocks.conf";
          fonts = {
            names = [ "xft:URWGothic-Book" ];
            size = 11.0;
          };
          extraConfig = ''
            icon_theme Arc
          '';
          colors = {
            background = "#222D31";
            statusline = "#F9FAF9";
            separator = "#454947";
            focusedWorkspace = {
              border = "#F9FAF9";
              background = "#16a085";
              text = "#292F34";
            };
            activeWorkspace = {
              border = "#595B5B";
              background = "#353836";
              text = "#FDF6E3";
            };
            inactiveWorkspace = {
              border = "#595B5B";
              background = "#222D31";
              text = "#EEE8D5";
            };
            urgentWorkspace = {
              border = "#16a085";
              background = "#FDF6E3";
              text = "#E5201D";
            };
            bindingMode = {
              border = "#16a085";
              background = "#2C2C2C";
              text = "#F9FAF9";
            };
          };
        }
      ];
    };
    extraConfig = ''
      assign [class = "^discord$"] 5
    '';
  };

  services.wlsunset = {
    enable = true;
    latitude = osConfig.location.latitude;
    longitude = osConfig.location.longitude;
  };
}
