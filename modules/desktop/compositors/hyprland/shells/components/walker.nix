{
  flake.modules.homeManager.desktop =
    {
      pkgs,
      lib,
      namespace,
      config,
      ...
    }:
    let
      cfg = config.${namespace}.desktop.compositors.hyprland._components.walker;
    in
    {
      options.${namespace}.desktop.compositors.hyprland._components.walker.enable = lib.mkOption {
        internal = true;
        type = lib.types.bool;
        default = false;
        description = "Enable the walker application launcher.";
      };

      config = lib.mkIf cfg.enable {
        services = {
          elephant.enable = true;
          walker = {
            enable = true;
            enableElephantIntegration = true;
          };
        };

        systemd.user.services = {
          elephant = lib.mkForce { };
          walker = lib.mkForce { };
        };

        wayland.windowManager.hyprland.settings = {
          exec-once = [
            "uwsm app -- ${lib.getExe pkgs.elephant}"
            "uwsm app -- ${lib.getExe pkgs.walker} --gapplication-service"
          ];
          bind = [
            "SUPER, R, exec, ${lib.getExe pkgs.walker}"
          ];
        };
      };
    };
}
