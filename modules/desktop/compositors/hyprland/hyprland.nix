# Hyprland Window Manager Module
{ ... }:
let
  shells = [
    "waybar"
    "ashell"
    "caelestia"
  ];
in
{
  # System Side Defaults
  flake.modules.nixos.desktop =
    {
      lib,
      pkgs,
      config,
      namespace,
      inputs,
      ...
    }:
    {
      options.${namespace}.desktop.compositors.hyprland = {
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

      config = lib.mkIf config.${namespace}.desktop.compositors.hyprland.enable {
        programs.hyprland = {
          enable = true;
          withUWSM = true;

          package = # UWSM Patches
            inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland.overrideAttrs (prev: {
              # Patch out unnecessary desktop entries
              postInstall = (prev.postInstall or "") + ''
                rm $out/share/wayland-sessions/hyprland.desktop
                sed -i 's/Name=Hyprland (uwsm-managed)/Name=Hyprland/' $out/share/wayland-sessions/hyprland-uwsm.desktop
                sed -i "s|start -e -D Hyprland hyprland.desktop|start -e -D Hyprland -- $out/bin/start-hyprland|" $out/share/wayland-sessions/hyprland-uwsm.desktop
              '';
              passthru.providedSessions = [ "hyprland-uwsm" ];
            });
        };
      };
    };

  # Home-Manager Configurations
  flake.modules.homeManager.desktop =
    {
      lib,
      pkgs,
      config,
      osConfig,
      namespace,
      ...
    }:
    {
      # User-Side Overrideables
      options.${namespace}.desktop.compositors.hyprland = {
        shell = lib.mkOption {
          type = lib.types.nullOr (lib.types.enum shells);
          default = osConfig.${namespace}.desktop.compositors.hyprland.shell;
          description = "Hyprland Shell To Use.";
        };
      };

      # User-Side Configurations
      config = lib.mkIf osConfig.${namespace}.desktop.compositors.hyprland.enable {
        home.packages = with pkgs; [
          grimblast
          libnotify
          nwg-displays
        ];

        programs = {
          satty.enable = true; # Screenshot Annotator
        };

        # Empty NWG-Displays Config to avoid Hyprland errors on source
        systemd.user.tmpfiles.rules = [
          "f ${config.home.homeDirectory}/.config/hypr/monitors.conf 0644 ${config.home.username} users -"
          "f ${config.home.homeDirectory}/.config/hypr/workspaces.conf 0644 ${config.home.username} users -"
        ];

        wayland.windowManager.hyprland = {
          enable = true;
          configType = "hyprlang";
          systemd.enable = false;

          # Use the host portal and package configuration.
          # Do NOT Remove.
          package = null;
          portalPackage = null;

          settings = {
            # Variables
            "$mainMod" = "SUPER";
            "$altMod" = "SHIFT";
            "$subMod" = "CONTROL";

            # Environment
            # Set XCursor and Hyprcursor from themes
            env = [
              "HYPRCURSOR_SIZE,24"
              "XCURSOR_SIZE,24"
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
            };

            dwindle = {
              preserve_split = true;
            };
            master.new_status = "master";

            # Visuals
            decoration = {
              active_opacity = 0.925;
              inactive_opacity = 0.75;
              rounding = 10;
              blur = {
                enabled = true;
                passes = 3;
                size = 5;
                vibrancy = 1.5;
                ignore_opacity = true;
                noise = 0.12;
                contrast = 2;
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

              # Screenshots
              ", PRINT, exec, grimblast copy area"
              "$altMod, PRINT, exec, grimblast save area - | satty --filename -f"

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

            layerrule = [
              "blur on, match:namespace notifications"
              "ignore_alpha 0, match:namespace notifications"
            ];

            source = [
              "${config.home.homeDirectory}/.config/hypr/monitors.conf"
              "${config.home.homeDirectory}/.config/hypr/workspaces.conf"
            ];
          };

          extraConfig = ''
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
          '';
        };
      };
    };
}
