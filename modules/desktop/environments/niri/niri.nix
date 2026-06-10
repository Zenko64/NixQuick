{ ... }:
let
  shells = [ ];
in
{
  flake.modules.nixos.desktop =
    {
      config,
      lib,
      pkgs,
      namespace,
      ...
    }:
    {
      options.${namespace}.desktop.environments.niri = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enables the Niri Window Manager.";
        };
        shell = lib.mkOption {
          type = lib.types.nullOr (lib.types.enum shells);
          default = null;
          description = "Niri Shell To Use.";
        };
      };

      config = lib.mkIf config.${namespace}.desktop.environments.niri.enable {
        programs.niri = {
          enable = true;
          useNautilus = true;
        };
      };
    };

  flake.modules.homeManager.desktop =
    {
      namespace,
      lib,
      osConfig,
      ...
    }:
    {
      options.${namespace}.desktop.environments.niri = {
        shell = lib.mkOption {
          type = lib.types.nullOr (lib.types.enum shells);
          default = osConfig.${namespace}.desktop.environments.niri.shell;
          description = "Niri Shell To Use.";
        };
      };

      config = lib.mkIf osConfig.${namespace}.desktop.environments.niri.enable {
      };
    };

}
