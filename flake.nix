{
  description = "Default NixQuick Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko.url = "github:nix-community/disko";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Frameworks
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";
    pkgs-by-name.url = "github:drupol/pkgs-by-name-for-flake-parts";
    easy-hosts.url = "github:tgirlcloud/easy-hosts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-topology.url = "github:oddlama/nix-topology";

    # Desktops
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      ...
    }:
    let
      libs = import ./libs/default.nix;
    in
    flake-parts.lib.mkFlake
      {
        inherit inputs;
        specialArgs = {
          nixquick = libs;
        };
      }
      (
        {
          lib,
          ...
        }:
        {
          systems = [
            "x86_64-linux"
            "aarch64-linux"
          ];
          imports = [ (inputs.import-tree ./flakeModules) ];
          debug = lib.mkForce true;

          # Where options should be namespaced.
          namespace = lib.mkDefault "local";
        }
      );
}
