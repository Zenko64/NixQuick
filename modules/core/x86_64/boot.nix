# Bootloader
{
  flake.modules.nixos.x86_64 =
    {
      config,
      namespace,
      lib,
      pkgs,
      ...
    }:
    {
      # Boot Options Declarations
      options.${namespace}.boot.secureBoot = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Secure Boot.";
      };

      config = {
        # BootLoader Configuration
        boot.loader.efi.canTouchEfiVariables = true;
        boot.loader.systemd-boot.enable = lib.mkDefault (!config.${namespace}.boot.secureBoot);
        boot.loader.systemd-boot.editor = false; # Security Measure

        # Boot-Related Dependencies
        environment.systemPackages = lib.mkIf config.${namespace}.boot.secureBoot [
          pkgs.sbctl
        ];

        # Lanzaboote SecureBoot Configuration
        boot.lanzaboote = lib.mkIf config.${namespace}.boot.secureBoot {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
          autoGenerateKeys.enable = true;
          autoEnrollKeys = {
            enable = true;
            autoReboot = true;
          };
        };
      };
    };
}
