{
  flake.modules.nixos.desktop =
    {
      namespace,
      pkgs,
      lib,
      config,
      ...
    }:
    {
      options.${namespace}.boot.splash = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable the boot screen.";
      };

      config = lib.mkIf config.${namespace}.boot.splash {
        boot.kernelParams = [
          "quiet"
          "splash"
          "loglevel=3"
          "rd.udev.log_level=3"
        ];

        stylix.targets.plymouth.enable = false;

        boot.plymouth = {
          enable = true;
          theme = "bootTheme";
          themePackages = [ pkgs.${namespace}.bootTheme ];
        };
      };
    };
}
