{
  flake.modules.homeManager.desktop =
    {
      lib,
      pkgs,
      namespace,
      config,
      ...
    }:
    let
      cfg = config.${namespace}.desktop.compositors.hyprland._components.hypridle;
    in
    {
      options.${namespace}.desktop.compositors.hyprland._components.hypridle = {
        enable = lib.mkOption {
          internal = true;
          type = lib.types.bool;
          default = false;
          description = "Enable the hypridle idle daemon.";
        };
        onIdle = lib.mkOption {
          internal = true;
          type = lib.types.nullOr (lib.types.str);
          default = null;
          description = "The command to trigger the lock screen.";
        };
      };

      config = lib.mkIf cfg.enable {
        services.hypridle = {
          enable = true;
          # WARN: Turning the display off before locking the screen can result in you getting stuck in a blackscreen.
          settings = {
            general = {
              after_sleep_cmd = "hyprctl dispatch dpms on";
            }
            // lib.optionalAttrs (cfg.onIdle != null) {
              before_sleep_cmd = cfg.onIdle;
            };

            listener = [
              {
                timeout = 150;
                on-timeout = "brightnessctl -sd rgb:kbd_backlight set 50%; brightnessctl -s set 50%";
                on-resume = "brightnessctl -rd rgb:kbd_backlight; brightnessctl -r";
              }
              {
                timeout = 225;
                on-timeout =
                  "brightnessctl -sd rgb:kbd_backlight set 0%; brightnessctl -s set 10%"
                  + lib.optionalString (cfg.onIdle != null) ("; " + cfg.onIdle);
                on-resume = "brightnessctl -rd rgb:kbd_backlight; brightnessctl -r";
              }
              {
                timeout = 300;
                on-timeout = "hyprctl dispatch dpms off";
                on-resume = "hyprctl dispatch dpms on";
              }
            ];
          };
        };

        systemd.user.services.hypridle = lib.mkForce { };

        wayland.windowManager.hyprland.settings.exec-once = [
          "uwsm app -- ${lib.getExe pkgs.hypridle}"
        ];
      };
    };
}
