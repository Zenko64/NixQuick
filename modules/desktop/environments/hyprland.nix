# TODO: On Enable, or Import, handle adding the user groups.
{
  flake.modules.nixos.desktops =
    {
      lib,
      config,
      namespace,
      ...
    }:
    let hyprOpts = config.${namespace}.desktop.environments.hyprland;
    in
    {
      options.${hyprOpts} = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether To Enable The Hyprland Module.";
        };
      };

      config = lib.mkIf hyprOpts.enable {
        programs.hyprland = {
          enable = true;
          withUWSM = true;
        };
      };
    };
}
