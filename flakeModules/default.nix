{
  inputs,
  config,
  lib,
  withSystem,
  ...
}:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.pkgs-by-name.flakeModule
    inputs.disko.flakeModule
    inputs.easy-hosts.flakeModule
    inputs.home-manager.flakeModules.home-manager

    (inputs.import-tree ../modules)
  ];
  options.namespace = lib.mkOption {
    type = lib.types.str;
    default = "local";
    description = "Namespace that holds all module options.";
  };

  config = {
    # Easy-Hosts Configuration
    easy-hosts = {
      path = ../hosts;
      autoConstruct = true;

      additionalClasses = {
        installer = "nixos";
        desktops = "nixos";
        servers = "nixos";
      };

      # Inject modules depending on host class
      perClass =
        class:
        let
          classMap = {
            installer = [
              config.flake.modules.nixos.installer
            ];
            desktops = [
              config.flake.modules.nixos.desktop
              config.flake.modules.nixos.features
              config.flake.modules.nixos.greeters
              {
                home-manager.sharedModules = [
                  config.flake.modules.homeManager.desktop
                  config.flake.modules.homeManager.programs
                ];
              }
            ];
            servers = [
              config.flake.modules.nixos.server
            ];
          };
        in
        {
          modules = classMap.${class} or [ ];
        };

      shared = {
        modules = [
          config.flake.modules.nixos.core
          inputs.disko.nixosModules.disko
          inputs.sops-nix.nixosModules.sops
          inputs.lanzaboote.nixosModules.lanzaboote

          { nixpkgs.overlays = [ config.flake.overlays.default ]; }

        ];

        specialArgs = {
          inputs = inputs;
          namespace = config.namespace;
        };
      };
    };

    # Overlay Definition That Injects Namespace Packages Into The Consumer
    flake.overlays.default =
      let
        namespace = config.namespace;
      in
      _: prev:
      withSystem prev.stdenv.hostPlatform.system (
        { config, ... }:
        {
          ${namespace} = config.packages;
        }
      );


    # Outputs For Each System
    perSystem =
      {
        pkgs,
        ...
      }:
      let
        netboot = config.flake.nixosConfigurations.netboot.config.system.build;
        iso = config.flake.nixosConfigurations.iso.config.system.build.isoImage;
        sdImage = config.flake.nixosConfigurations.sdImage.config.system.build.sdImage;
      in
      {
        # * Buildables *
        packages = {
          sdImage = sdImage;
          iso = iso;
          default = iso;
        };

        # * Where PKGS-BY-NAME looks for packages *
        pkgsDirectory = ../packages;

        # * Development Shells *
        devShells = {
          # Main Development Shell
          default = pkgs.mkShell {
            packages = [
              pkgs.nixd
              pkgs.nixfmt

              # Feature CLIs
              pkgs.sops
              (pkgs.writeShellScriptBin "installers" ''
                ${lib.getExe pkgs.nix} develop .#installers
              '')
            ];

            shellHook = ''
              clear
              # Intro Message
              echo "----- NixQuick Development Shell -----"
              echo "Commands:"
              echo " - installers: Loads The Installers DevShell"
              echo "--------------------------------------"
            '';
          };

          # Installers DevShell
          installers = pkgs.mkShell {
            packages = [
              pkgs.nixos-anywhere
              pkgs.pixiecore

              # Starts Pixiecore to netboot a debuggee on the same network.
              # Requires a DHCP server and internet on the LAN.
              (pkgs.writeShellScriptBin "netboot" ''
                sudo ${pkgs.pixiecore}/bin/pixiecore \
                  boot ${netboot.kernel}/bzImage ${netboot.netbootRamdisk}/initrd \
                  --cmdline "init=${netboot.toplevel}/init loglevel=4" --debug \
                  --dhcp-no-bind \
                  --port 64172 --status-port 64172 "$@"
              '')
            ];

            shellHook = ''
              clear
              # Intro Message
              echo "----- NixQuick Installers DevShell -----"
              echo "Commands:"
              echo " - netboot: Builds the ISO Installer"
              echo "-----------------------------------------"
            '';
          };
        };
      };
  };
}
