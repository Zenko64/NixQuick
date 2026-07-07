{
  flake.modules.homeManager.desktop =
    {
      lib,
      pkgs,
      config,
      osConfig,
      namespace,
      inputs,
      ...
    }:
    {
      imports = [
        inputs.caelestia-shell.homeManagerModules.default
      ];

      config = lib.mkMerge [
        # Register the shell into the shell registry
        { ${namespace}.desktop.compositors.hyprland._shells = [ "caelestia" ]; }

        # Guard The Shell
        (lib.mkIf
          (
            osConfig.${namespace}.desktop.compositors.hyprland.enable
            && config.${namespace}.desktop.compositors.hyprland.shell == "caelestia"
          )
          {
            ${namespace}.desktop.compositors.hyprland._components = {
              hyprpolkit.enable = true;
              cliphist.enable = true;
            };

            programs.caelestia = {
              enable = true;
              systemd.enable = false;
              cli = {
                enable = true;
                settings = {
                  theme.enableGtk = false;
                };
              };
              settings = {
                border.rounding = 15;
                dashboard.showOnHover = false;
                appearance = {
                  transparency = {
                    enabled = true;
                    base = 0.75;
                    layers = 0.75;
                  };
                };
                general = {
                  apps = {
                    terminal = [ "${lib.getExe pkgs.kitty}" ];
                    audio = [ "${lib.getExe pkgs.pwvucontrol}" ];
                    playback = [ "${lib.getExe pkgs.mpv}" ];
                    explorer = [ "${lib.getExe pkgs.nautilus} --new-window" ];
                  };
                };
                services = {
                  useFahrenheit = false;
                  useTwelveHourClock = true;
                };
                utilities.toasts = {
                  chargingChanged = false;
                  capsLockChanged = false;
                  numLockChanged = false;
                };
                paths = {
                  wallpaperDir = "${config.home.homeDirectory}/.wallpapers";
                };
              };
            };

            # Hyprland Shell-Specifics
            wayland.windowManager.hyprland.settings = {
              general.gaps_out = lib.mkForce "5 5 5 5";
              bind = [ "$mainMod, R, exec, caelestia shell drawers toggle launcher" ];
              exec-once = [ "uwsm app -- caelestia shell -d" ];
            };
          }
        )
      ];
    };
}
