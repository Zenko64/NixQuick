{
  import-tree,
  inputs,
  ...
}:
{
  config,
  withSystem,
  ...
}:
{

  # Flake Modules To Import (Flake-Parts only)
  imports = [
    inputs.disko.flakeModule
    inputs.easy-hosts.flakeModule
    inputs.flake-parts.flakeModules.modules
    inputs.pkgs-by-name.flakeModule
    inputs.home-manager.flakeModules.home-manager
    inputs.nix-topology.flakeModule

    (import-tree ./lib)

    # Inject all the modules in the dirtree into flake-parts
    (import-tree ./modules)
  ];

  easy-hosts = {
    hosts = {
      iso = {
        arch = "x86_64";
        class = "installer";
        path = ./hosts/x86_64-installer/iso;
      };
      netboot = {
        arch = "x86_64";
        class = "installer";
        path = ./hosts/x86_64-installer/netboot;
      };
      sdImage = {
        arch = "aarch64";
        class = "installer";
        path = ./hosts/aarch64-installer/sdImage;
      };
    };
    additionalClasses = {
      installer = "nixos";
      desktops = "nixos";
      servers = "nixos";
    };

    # Injects architecture specific core modules, if they exist.
    perArch = arch: {
      modules =
        if config.flake.modules.nixos ? ${arch} then [ config.flake.modules.nixos.${arch} ] else [ ];
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
            # Inject Home-Manager Modules
            {
              home-manager.sharedModules = [
                config.flake.modules.homeManager.desktop
              ];
            }
            inputs.stylix.nixosModules.stylix
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
        inherit inputs;
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
      pkgsDirectory = ./packages;

      # * Development Shell *
      devShells.default = pkgs.mkShell {
        buildInputs = [
          pkgs.nixd
          pkgs.nixfmt

          # Feature CLIs
          pkgs.sops

          # Lab testing machine
          pkgs.dnsmasq
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
          # Intro Message
          echo "----- NixQuick Development Shell -----"
          echo "Commands:"
          echo " - netboot: Start Installer PXEServer with OpenSSH Enabled."
          echo "--------------------------------------"
        '';
      };
    };
}
