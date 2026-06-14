# Boot & Kernel
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
        default = true;
        description = "Enable Secure Boot.";
      };

      config = {
        # BootLoader Configuration
        boot.loader.efi.canTouchEfiVariables = true;
        boot.loader.systemd-boot.editor = false; # Security Measure

        # Lanzaboote overrides Default SystemD-Boot, it must be disabled if SB is ON.
        # TODO: Test what happens if we actually leave this through as of today when safe, keep as by docs for now
        boot.loader.systemd-boot.enable = (!config.${namespace}.boot.secureBoot);

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
