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
      cfg = config.${namespace}.desktop.compositors.hyprland._components.hyprpolkit;
    in
    {
      options.${namespace}.desktop.compositors.hyprland._components.hyprpolkit.enable = lib.mkOption {
        internal = true;
        type = lib.types.bool;
        default = false;
        description = "Enable the hyprpolkitagent authentication agent.";
      };

      config = lib.mkIf cfg.enable {
        services.hyprpolkitagent.enable = true;

        systemd.user.services.hyprpolkitagent = lib.mkForce { };

        wayland.windowManager.hyprland.settings = {
          exec-once = [
            "uwsm app -- ${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
          ];
        };
      };
    };
}
