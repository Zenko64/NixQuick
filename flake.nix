{
  description = "My Custom NixOS Configuration.";

  inputs = {
    # System
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko.url = "github:nix-community/disko";

    # Frameworks
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";
    easy-hosts.url = "github:tgirlcloud/easy-hosts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Theming
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      import-tree,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { config, ... }:
      {
        # ! Do NOT Disable This!
        # Disabling This Will Break Auto-completion, and therefore making it unnecessarily more difficult to use this.
        debug = true;

        # Namespace that holds every injected module options
        namespace = "local";

        # Supported core architectures
        systems = [ "x86_64-linux" ];

        # Flake Modules To Import (Flake-Parts only)
        imports = [
          inputs.disko.flakeModule
          inputs.easy-hosts.flakeModule
          inputs.flake-parts.flakeModules.modules
          inputs.home-manager.flakeModules.home-manager

          (import-tree ./lib)

          # Inject all the modules in the dirtree into flake-parts
          (import-tree ./modules)
        ];

        easy-hosts = {
          path = ./hosts;
          autoConstruct = true;
          additionalClasses = {
            desktops = "nixos";
            servers = "nixos";
          };
          perClass =
            class:
            let
              classMap = {
                desktops = [
                  config.flake.modules.nixos.desktop
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
          shared = {
            # Loads modules that can either bring behavior, or options that cause behavior.
            modules = [
              # Libs
              inputs.disko.nixosModules.disko

              # Core Modules
              config.flake.modules.nixos.core
            ];
            specialArgs = {
              inherit inputs;
              namespace = config.namespace;
            };
          };
        };

        perSystem =
          { pkgs, ... }:
          let
            installer = inputs.self.nixosConfigurations.installer.config.system.build;
          in
          {
            devShells.default = pkgs.mkShell {
              buildInputs = [
                pkgs.nixd
                pkgs.nixfmt

                # Lab testing machine
                pkgs.dnsmasq
                pkgs.nixos-anywhere
                pkgs.pixiecore

                # Starts Pixiecore to netboot a debuggee on the same network.
                # Requires a DHCP server and internet on the LAN.
                (pkgs.writeShellScriptBin "netboot" ''
                  sudo ${pkgs.pixiecore}/bin/pixiecore \
                    boot ${installer.kernel}/bzImage ${installer.netbootRamdisk}/initrd \
                    --cmdline "init=${installer.toplevel}/init loglevel=4" --debug \
                    --dhcp-no-bind \
                    --port 64172 --status-port 64172 "$@"
                '')
              ];
            };
          };
      }
    );
}
