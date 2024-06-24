{
  lib,
  username,
  host,
  inputs,
  pkgs,
  config,
  ...
}:

{
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;

    config = rec {
      modifier = "Mod4";
      bars = [
        {
          position = "top";
          trayOutput = "primary";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3/config.toml";
          fonts = {
            names = [" pango:Fira Code Regular" "FontAwesome5Free" ];
            size = 10.0;
          };
          extraConfig =  "
          height 14
          padding 5px 0 0 0";

        }
      ];

      window = {
        border = 1;
        titlebar = false;
      };

      gaps = {
        inner = 10;
        smartGaps = true;
      };

      workspaceOutputAssign = [
        {
          workspace = "1";
          output = "DP-1";
        }
        {
          workspace = "2";
          output = "HDMI-0";
        }
        {
          workspace = "3";
          output = "DP-5";
        }
        {
          workspace = "4";
          output = "DP-3";
        }
      ];

      fonts = {
        names = [ "pango:Fira Code" ];
        style = "Regular";
        size = 8.0;
      };

      keybindings = lib.mkOptionDefault {
        "${modifier}+q" = "kill";
        "${modifier}+Return" = "exec ${pkgs.kitty}/bin/kitty";
        "${modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -modi drun -show drun -show-icons";
        "${modifier}+Shift+Return" = "exec thunar";
        "Ctrl+Mod1+f" = "exec floorp";
        "Ctrl+Mod1+g" = "exec floorp --private-window";
        "Ctrl+Mod1+d" = "exec discord";
        "Ctrl+Mod1+e" = "exec code";
      };

      startup = [
        {
          command = "autotiling";
          always = true;
          notification = false;
        }
        {
          command = "nitrogen --restore";
          always = true;
          notification = false;
        }
      ];
    };
  };
}
