{
  config,
  inputs,
  ...
}:
{
  imports = [ inputs.nix-topology.flakeModule ];

  perSystem = { system, ... }: {
    packages = {
      topology = config.flake.topology.${system}.config.output;
    };
  };

  flake.modules.nixos.server.imports = [ inputs.nix-topology.nixosModules.default ];
}
