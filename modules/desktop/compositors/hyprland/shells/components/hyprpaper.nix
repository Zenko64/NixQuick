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
      cfg = config.${namespace}.desktop.compositors.hyprland._components.hyprpaper;
    in
    {
      options.${namespace}.desktop.compositors.hyprland._components.hyprpaper.enable = lib.mkOption {
        internal = true;
        type = lib.types.bool;
        default = false;
        description = "Enable the hyprpaper wallpaper daemon.";
      };

      config = lib.mkIf cfg.enable {
        services.hyprpaper.enable = true;

        systemd.user.services.hyprpaper = lib.mkForce { };

        wayland.windowManager.hyprland.settings = {
          exec-once = [
            "uwsm app -- ${lib.getExe pkgs.hyprpaper}"
          ];
        };
      };
    };
}
