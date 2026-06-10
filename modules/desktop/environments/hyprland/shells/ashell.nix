{
  flake.modules.homeManager.desktop =
    {
      lib,
      osConfig,
      config,
      namespace,
      pkgs,
      ...
    }:
    {
      config =
        lib.mkIf
          (
            osConfig.${namespace}.desktop.environments.hyprland.enable == true
            && config.${namespace}.desktop.environments.hyprland.shell == "ashell"
          )
          {
            programs.ashell.enable = true;

            home.packages = with pkgs; [
              mako
              elephant
              walker
            ];

            wayland.windowManager.hyprland.settings = {
              exec-once = [
                "uwsm app -- ${lib.getExe pkgs.ashell}"
                "uwsm app -- ${lib.getExe pkgs.mako}"
                "uwsm app -- ${lib.getExe pkgs.elephant}"
                "uwsm app -- ${lib.getExe pkgs.walker} --gapplication-service"
              ];
              bind = [
                "bind = SUPER, R, exec, ${lib.getExe pkgs.walker}"
              ];
            };

            wayland.windowManager.hyprland.extraConfig = ''
              layerrule = blur on, match:namespace ashell-main-layer
              layerrule = ignore_alpha 0, match:namespace ashell-main-layer
            '';
          };
    };
}
