# Hyprland Shell Registry Module
{
  flake.modules.homeManager.desktop =
    {
      config,
      lib,
      namespace,
      ...
    }:
    let
      cfg = config.${namespace}.desktop.compositors.hyprland;
    in
    {
      # Shell Registry
      options.${namespace}.desktop.compositors.hyprland = {
        _shells = lib.mkOption { # Push Your Shells Name Here From Their Module
          internal = true;
          default = [ ];
          type = lib.types.listOf lib.types.str;
          description = "Hyprland Shell Registry.";
        };
        shell = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Which Hyprland Shell To Enable. (Must exist in the shell registry.)";
        };
      };

      # Check if current shell is null or an element of the registry
      config.assertions = [
        {
          assertion = cfg.shell == null || builtins.elem cfg.shell cfg._shells;
          message = "[ ${namespace}.desktop.compositors.hyprland.shell ]: \"${toString cfg.shell}\" is not a registered shell. Available: ${builtins.concatStringsSep ", " cfg._shells}.";
        }
      ];
    };
}
