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
      bars = [ ];

      window.border = 0;

      gaps = {
        inner = 10;
        smart_gaps on
        
      };

    keybindings = lib.mkOptionDefault {
      "${modifier}+Return" = "exec ${pkgs.kitty}/bin/kitty";
      "${modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -modi drun -show drun -show-icons";
      
      "${modifier}+b" = "exec ${pkgs.brave}/bin/brave";
      "${modifier}+Shift+x" = "exec systemctl suspend";
      "${modifier}+Shift+Return" = "exec thunar";
      "Ctrl+Mod1+f" = "exec floorp";
      "Ctrl+Mod1+g" = "exec floorp --private-window";
      "Ctrl+Mod1+d" = "exec discord";
      "Ctrl+Mod1+e" = "exec code";
      "mode = "Exit (L)ogout, (R)eboot, (P)oweroff" {
        "r" = "exec systemctl reboot";
        "l" = "exit";
        "p" = "exec systemctl poweroff";
      }";
      "${modifier}+Shift+e" = "exec mode "Exit (L)ogout, (R)eboot, (P)oweroff'";
      "Return" = "Return mode 'default'";
      "Escape" = "Escape mode 'default'";
    };

      startup = [
        {
          command = "exec i3-msg workspace 1";
          always = true;
          notification = false;
        }
        {
          command = "systemctl --user restart polybar.service";
          always = true;
          notification = false;
        }
        {
          command = "${pkgs.feh}/bin/feh --bg-scale ~/background.png";
          always = true;
          notification = false;
        }
      ];
    };
  };
}
