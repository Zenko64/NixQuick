{
  flake.modules.homeManager.desktop =
    {
      lib,
      namespace,
      config,
      ...
    }:
    let
      cfg = config.${namespace}.desktop.compositors.hyprland._components.hyprlock;
    in
    {
      options.${namespace}.desktop.compositors.hyprland._components.hyprlock.enable = lib.mkOption {
        internal = true;
        type = lib.types.bool;
        default = false;
        description = "Enable the hyprlock lock screen.";
      };

      config = lib.mkIf cfg.enable {
        wayland.windowManager.hyprland.settings.settings.bind = [
          "$mainMod $altMod, L, exec, hyprlock"
        ];

        stylix.targets.hyprlock.image.enable = false;
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
              background = {
                path = "screenshot";
                blur_passes = 4;
                blur_size = 8;
              };
            };
          };
        };
      };
    };
}
