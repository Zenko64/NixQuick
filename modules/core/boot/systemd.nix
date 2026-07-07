# SystemD-Boot Module
{
  flake.modules.nixos.core =
    {
      config,
      namespace,
      lib,
      pkgs,
      ...
    }:
    let
      systemd-boot = config.${namespace}.boot.loader.systemd-boot;
    in
    {
      # Boot Options Declarations
      options.${namespace}.boot.loader.systemd-boot = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable Systemd-Boot.";
        };
        secureBoot = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable Secure Boot (replaces Systemd-Boot with lanzaboote).";
        };
      };

      config = lib.mkMerge [
        (lib.mkIf systemd-boot.enable {
          boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
          boot.loader.systemd-boot.enable = !systemd-boot.secureBoot; # SystemD-Boot must be false if secureBoot is on, as Lanzaboote replaces it.
        })

        (lib.mkIf systemd-boot.secureBoot {
          ${namespace}.boot.loader.systemd-boot.enable = true;
          environment.systemPackages = [ pkgs.sbctl ];
          boot.lanzaboote = {
            enable = true;
            pkiBundle = "/var/lib/sbctl";
            autoGenerateKeys.enable = true;
            autoEnrollKeys = {
              enable = true;
              autoReboot = true;
            };
          };
        })
      ];
    };
}
