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
      cfg = config.${namespace}.desktop.compositors.hyprland._components.mako;
    in
    {
      options.${namespace}.desktop.compositors.hyprland._components.mako.enable = lib.mkOption {
        internal = true;
        type = lib.types.bool;
        default = false;
        description = "Enable the mako notification daemon.";
      };

      config = lib.mkIf cfg.enable {
        services.mako.enable = true;

        systemd.user.services.mako = lib.mkForce { };

        wayland.windowManager.hyprland.settings = {
          exec-once = [
            "uwsm app -- ${lib.getExe pkgs.mako}"
          ];
        };
      };
    };
}
