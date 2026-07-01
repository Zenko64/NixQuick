{
  import-tree,
  inputs,
  ...
}:
{
  config,
  lib,
  withSystem,
  self,
  ...
}:
{
  # Flake Modules To Import
  imports = [
    # Libraries
    inputs.disko.flakeModule
    inputs.easy-hosts.flakeModule
    inputs.flake-parts.flakeModules.modules
    inputs.pkgs-by-name.flakeModule
    inputs.home-manager.flakeModules.home-manager
    inputs.nix-topology.flakeModule

    # Main System Modules
    (import-tree ../modules)
  ];

  options.namespace = lib.mkOption {
    type = lib.types.str;
    default = "local";
    description = "Namespace that holds all module options.";
  };

  config = {
    easy-hosts = {
      path = ./hosts;
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
              # Inject Home-Manager Modules
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

      # Code shared across all hosts
      shared = {
        # Loads modules that can either bring behavior, or options that cause behavior.
        modules = [
          # Libs
          inputs.disko.nixosModules.disko
          inputs.sops-nix.nixosModules.sops
          inputs.lanzaboote.nixosModules.lanzaboote
          inputs.nix-topology.nixosModules.default

          # Inject overlay definition
          { nixpkgs.overlays = [ config.flake.overlays.default ]; }

          config.flake.modules.nixos.core
        ];

        specialArgs = {
          inputs = inputs // {
            inherit self;
          };
          namespace = config.namespace;
        };
      };
    };

    # * Overlay Definition that injects flake packages into Nixpkgs (pkgs.${namespace}) *
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

    # * Ouputs that run for every system *
    perSystem =
      {
        pkgs,
        system,
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
          topology = config.flake.topology.${system}.config.output;
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
