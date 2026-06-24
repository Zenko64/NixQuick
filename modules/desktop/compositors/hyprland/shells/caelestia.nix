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

      config =
        lib.mkIf
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
                appearance = {
                  transparency = {
                    enabled = true;
                    base = 0.75;
                    layers = 0.75;
                  };
                };
                general = {
                  apps = {
                    audio = lib.getExe pkgs.pwvucontrol;
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

            # Binds
            wayland.windowManager.hyprland.settings = {
              bind = [ "$mainMod, R, exec, caelestia shell drawers toggle launcher" ];
              exec-once = [ "uwsm app -- caelestia shell -d" ];
            };
          };
    };
}
