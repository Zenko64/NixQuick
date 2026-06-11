# Hyprland Window Manager Module
{ ... }:
let
  shells = [
    "ashell"
    "caelestia"
  ];
in
{
  flake.modules.nixos.desktop =
    {
      config,
      lib,
      pkgs,
      namespace,
      ...
    }:
    {
      options.${namespace}.desktop.environments.hyprland = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enables the Hyprland Window Manager.";
        };
        shell = lib.mkOption {
          type = lib.types.nullOr (lib.types.enum shells);
          default = "ashell";
          description = "Hyprland Shell To Use.";
        };
      };

      config = lib.mkIf config.${namespace}.desktop.environments.hyprland.enable {
        programs.hyprland = {
          enable = true;
          withUWSM = true;
          # This is to use only with UWSM
          package = pkgs.hyprland.overrideAttrs (prev: {
            # Extend the post-install script to remove what we don't need to ensure a good UX
            # Deletes Non-UWSM Hyprland, Renames Desktop-Name Hyprland branding to just Hyprland.
            postInstall = (prev.postInstall or "") + ''
              rm $out/share/wayland-sessions/hyprland.desktop
              sed -i 's/Name=Hyprland (uwsm-managed)/Name=Hyprland/' $out/share/wayland-sessions/hyprland-uwsm.desktop
              sed -i "s|start -e -D Hyprland hyprland.desktop|start -e -D Hyprland -- $out/bin/hyprland|" $out/share/wayland-sessions/hyprland-uwsm.desktop
            '';
            passthru.providedSessions = [ "hyprland-uwsm" ];
          });
        };
      };
    };

  flake.modules.homeManager.desktop =
    {
      config,
      lib,
      osConfig,
      pkgs,
      namespace,
      ...
    }:
    {
      options.${namespace}.desktop.environments.hyprland = {
        shell = lib.mkOption {
          type = lib.types.nullOr (lib.types.enum shells);
          default = osConfig.${namespace}.desktop.environments.hyprland.shell;
          description = "Hyprland Shell To Use.";
        };
      };

      config = lib.mkIf osConfig.${namespace}.desktop.environments.hyprland.enable {
        home.packages = with pkgs; [
          hyprpaper
          hypridle
          hyprpolkitagent
          cliphist
          grimblast
          libnotify
          nwg-displays
          wl-clipboard
          nautilus
        ];

        services = {
          hypridle = {
            enable = true;
            # WARN: Turning the display off before locking the screen can result in you getting stuck in a blackscreen.
            settings = {
              general = {
                before-sleep = "hyprlock";
                after-sleep = "hyprctl dispatch dpms on";
              };
              listener = [
                {
                  timeout = 150;
                  on-timeout = "brightnessctl -sd rgb:kbd_backlight set 0%; brightnessctl -s set 10%; hyprlock";
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
        };
        systemd.user.services.hypridle = lib.mkForce {};

        programs = {
          hyprlock = {
            enable = true;
            settings = {
              general = {
                hide_cursor = true;
                ignore_empty_input = true;
              };
              animations = {
                enabled = true;
                fade_in = {
                  duration = 300;
                  bezier = "easeOutQuint";
                };
                fade_out = {
                  duration = 300;
                  bezier = "easeOutQuint";
                };
              };
              background = lib.mkForce {
                blur_passes = lib.mkForce 3;
                blur_size = lib.mkForce 8;
              };
            };
          };

          # Default Apps
          kitty.enable = true; # Kitty is the default terminal
          satty.enable = true; # Satty is a Screenshot annotator
        };

        # Create Empty File For NWG-Displays That Hyprland Sources
        systemd.user.tmpfiles.rules = [
          "f /home/${config.home.username}/.config/hypr/monitors.conf 0644 ${config.home.username} users -"
          "f /home/${config.home.username}/.config/hypr/workspaces.conf 0644 ${config.home.username} users -"
        ];

        wayland.windowManager.hyprland = {
          enable = true;
          configType = "hyprlang";
          systemd.enable = false;

          # Use the host portal and package configuration.
          # Don't remove this
          package = null;
          portalPackage = null;

          settings = {
            # Initial Execution
            exec-once = [
              "uwsm app -- ${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
              "uwsm app -- ${lib.getExe pkgs.hyprpaper}"
              "uwsm app -- ${lib.getExe pkgs.hypridle}"
              "uwsm app -- ${lib.getExe pkgs.cliphist}"
            ];

            # Variables
            "$terminal" = "${lib.getExe pkgs.kitty}";
            "$fileManager" = "${lib.getExe pkgs.nautilus}";
            "$mainMod" = "SUPER";
            "$altMod" = "SHIFT";
            "$subMod" = "CONTROL";

            # Environment
            env = [
              "HYPRCURSOR_SIZE,24"
              "HYPRCURSOR_THEME,Nordzy-hyprcursor-catppuccin-mocha-sky"
              "XCURSOR_SIZE,24"
              "XCURSOR_THEME,Nordzy-catppuccin-mocha-sky"
            ];

            # Layout
            general = {
              allow_tearing = false;
              border_size = 3;
              extend_border_grab_area = 15;
              gaps_in = 8;
              gaps_out = "15";
              layout = "dwindle";
              resize_on_border = true;
              # New lesson: Stuff that can be undefined, or as part of a different module, must be shallowly merged instead of hardcoded defaults, to avoid weird errors.
            }
            // lib.optionalAttrs osConfig.stylix.enable {
              "col.active_border" = lib.mkForce "rgba(ff96dcf2) rgba(468796f2) 45deg";
              "col.inactive_border" = lib.mkForce "rgba(${config.lib.stylix.colors.base01}ff)";
            };

            dwindle = {
              preserve_split = true;
            };

            master.new_status = "master";

            # Visuals
            decoration = {
              active_opacity = 0.95;
              inactive_opacity = 0.8;
              rounding = 10;
              blur = {
                enabled = true;
                passes = 2;
                size = 7;
                vibrancy = 1;
              };
            };

            # Animations
            animations = {
              enabled = true;
              bezier = [
                "easeOutQuint,   0.23, 1,    0.32, 1"
                "easeInOutCubic, 0.65, 0.05, 0.36, 1"
                "linear,         0,    0,    1,    1"
                "almostLinear,   0.5,  0.5,  0.75, 1"
                "quick,          0.15, 0,    0.1,  1"
              ];
              animation = [
                "borderangle,   1, 250,  linear,       loop"
                "global,        1, 10,   default"
                "border,        1, 5.5, easeOutQuint"
                "windows,       1, 4.8, easeOutQuint"
                "windowsIn,     1, 4.2,  easeOutQuint, popin 85%"
                "windowsOut,    1, 1.5, linear,       popin 85%"
                "fadeIn,        1, 1.75, almostLinear"
                "fadeOut,       1, 1.5, almostLinear"
                "fade,          1, 3, quick"
                "layers,        1, 3.8, easeOutQuint"
                "layersIn,      1, 4,    easeOutQuint, fade"
                "layersOut,     1, 1.5,  linear,       fade"
                "fadeLayersIn,  1, 1.8, almostLinear"
                "fadeLayersOut, 1, 1.3, almostLinear"
                "workspaces,    1, 2, almostLinear, fade"
                "workspacesIn,  1, 1.25, almostLinear, fade"
                "workspacesOut, 1, 2, almostLinear, fade"
                "zoomFactor,    1, 7,    quick"
              ];
            };

            # Input
            input = {
              follow_mouse = 1;
              sensitivity = 0;
              touchpad = {
                clickfinger_behavior = true;
                natural_scroll = true;
              };
            };
            gesture = "3, horizontal, workspace";

            # Keybinds
            bind = [
              # TODO: Add Media Keys

              # Lock Screen
              "$mainMod $altMod, L, exec, hyprlock"

              # Screenshots
              ", PRINT, exec, grimblast copy area"
              "$altMod, PRINT, exec, grimblast save area - | satty --filename -f"

              # App launchers
              "$mainMod, T, exec, $terminal"
              "$mainMod, E, exec, $fileManager"

              # Window focus
              "$mainMod, W, movefocus, u"
              "$mainMod, A, movefocus, l"
              "$mainMod, S, movefocus, d"
              "$mainMod, D, movefocus, r"
              "$mainMod, up,    movefocus, u"
              "$mainMod, left,  movefocus, l"
              "$mainMod, down,  movefocus, d"
              "$mainMod, right, movefocus, r"

              # Window move
              "$mainMod $altMod, W, movewindow, u"
              "$mainMod $altMod, A, movewindow, l"
              "$mainMod $altMod, S, movewindow, d"
              "$mainMod $altMod, D, movewindow, r"
              "$mainMod $altMod, up,    movewindow, u"
              "$mainMod $altMod, left,  movewindow, l"
              "$mainMod $altMod, down,  movewindow, d"
              "$mainMod $altMod, right, movewindow, r"

              # Workspace switch
              "$mainMod, 1, workspace, 1"
              "$mainMod, 2, workspace, 2"
              "$mainMod, 3, workspace, 3"
              "$mainMod, 4, workspace, 4"
              "$mainMod, 5, workspace, 5"
              "$mainMod, 6, workspace, 6"
              "$mainMod, 7, workspace, 7"
              "$mainMod, 8, workspace, 8"
              "$mainMod, 9, workspace, 9"
              "$mainMod, 0, workspace, 10"

              # Workspace move
              "$mainMod $altMod, 1, movetoworkspace, 1"
              "$mainMod $altMod, 2, movetoworkspace, 2"
              "$mainMod $altMod, 3, movetoworkspace, 3"
              "$mainMod $altMod, 4, movetoworkspace, 4"
              "$mainMod $altMod, 5, movetoworkspace, 5"
              "$mainMod $altMod, 6, movetoworkspace, 6"
              "$mainMod $altMod, 7, movetoworkspace, 7"
              "$mainMod $altMod, 8, movetoworkspace, 8"
              "$mainMod $altMod, 9, movetoworkspace, 9"
              "$mainMod $altMod, 0, movetoworkspace, 10"

              # Special workspace
              "$mainMod, Z, togglespecialworkspace, Magic"
              "$mainMod $altMod, Z, movetoworkspace, special:Magic"

              # Window control
              "$mainMod $altMod, Q, killactive"
              "$mainMod $altMod, F, fullscreen,"
              "$mainMod $altMod, X, layoutmsg, togglesplit"
              "$mainMod $subMod, F, togglefloating"
              "$mainMod $subMod, Space, pseudo"

              # Mouse workspace switch
              "$mainMod, mouse_down, workspace, e+1"
              "$mainMod, mouse_up,   workspace, e-1"
            ];

            binde = [
              "$mainMod $subMod, W, resizeactive, 0 -50"
              "$mainMod $subMod, A, resizeactive, -50 0"
              "$mainMod $subMod, S, resizeactive, 0 50"
              "$mainMod $subMod, D, resizeactive, 50 0"
              "$mainMod $subMod, up,    resizeactive, 0 -50"
              "$mainMod $subMod, left,  resizeactive, -50 0"
              "$mainMod $subMod, down,  resizeactive, 0 50"
              "$mainMod $subMod, right, resizeactive, 50 0"
            ];

            bindm = [
              "$mainMod, mouse:272, movewindow"
              "$mainMod, mouse:273, resizewindow"
            ];
          };

          extraConfig = ''
            source = ~/.config/hypr/monitors.conf
            source = ~/.config/hypr/workspaces.conf

            windowrule {
                name = suppress-maximize-events
                match:class = .*
                suppress_event = maximize
            }

            windowrule {
                name = fix-xwayland-drags
                match:class = ^$
                match:title = ^$
                match:xwayland = true
                match:float = true
                match:fullscreen = false
                match:pin = false
                no_focus = true
            }

            layerrule = blur on, match:namespace notifications
            layerrule = ignore_alpha 0, match:namespace notifications
          '';
        };
      };
    };
}
