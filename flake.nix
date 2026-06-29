{
  description = "Default NixQuick Configuration";

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
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Utilities
    nix-topology.url = "github:oddlama/nix-topology";

    # Frameworks
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";
    pkgs-by-name.url = "github:drupol/pkgs-by-name-for-flake-parts";
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

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
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
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        lib,
        flake-parts-lib,
        ...
      }:
      let
        inherit (flake-parts-lib) importApply;
        flakeModules.default = importApply ./flake-module.nix {
          inherit inputs;
          import-tree = inputs.import-tree;
        };
      in
      {
        # ! Do NOT Disable This!
        # Disabling This Will Break Auto-completion, and therefore making it unnecessarily more difficult to use this.
        debug = lib.mkForce true;

        imports = [ flakeModules.default ];

        # Namespace that holds every injected module options
        namespace = lib.mkDefault "local";

        # Supported core architectures
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        # Export flake modules
        flake.flakeModules.default = flakeModules.default;
      }
    );
}
