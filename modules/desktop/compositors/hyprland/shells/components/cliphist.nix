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
      cfg = config.${namespace}.desktop.compositors.hyprland._components.cliphist;
    in
    {
      options.${namespace}.desktop.compositors.hyprland._components.cliphist.enable = lib.mkOption {
        internal = true;
        type = lib.types.bool;
        default = false;
        description = "Enable the cliphist clipboard history manager.";
      };

      config = lib.mkIf cfg.enable {
        home.packages = with pkgs; [
          wl-clipboard
          cliphist
        ];

        wayland.windowManager.hyprland.settings = {
          exec-once = [
            "uwsm app -- ${lib.getExe' pkgs.wl-clipboard "wl-paste"} --watch ${lib.getExe pkgs.cliphist} store"
          ];
        };
      };
    };
}
