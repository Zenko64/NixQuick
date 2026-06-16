{
  description = "My Custom NixOS Configuration.";

  inputs = {
    # System
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware = {
      # Hardware Specific Patches (Check Repo For How-To-Use)
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko.url = "github:nix-community/disko"; # Auto-Disk Formatting
    lanzaboote = {
      # Secure Boot
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Frameworks
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";
    easy-hosts.url = "github:tgirlcloud/easy-hosts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Desktops
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

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
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

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
          perArch = arch: {
            modules =
              if config.flake.modules.nixos ? ${arch} then [ config.flake.modules.nixos.${arch} ] else [ ];
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
              inputs.sops-nix.nixosModules.sops
              inputs.lanzaboote.nixosModules.lanzaboote

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
            netboot = inputs.self.nixosConfigurations.netboot.config.system.build;
            iso = inputs.self.nixosConfigurations.iso.config.system.build.isoImage;
          in
          {
            packages = {
              iso = iso;
              default = iso;
            };
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
                sops git-hook install

                # Intro Message
                echo "-----Zenko64's NixOS Development Shell-----"
                echo "Commands:"
                echo " - netboot: Start Installer PXEServer with OpenSSH Enabled."
                echo "-------------------------------------------"
              '';
            };
          };
      }
    );
}
