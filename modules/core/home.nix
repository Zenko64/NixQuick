# Base Home-Manager Configuration
{
  flake.modules.nixos.core =
    { inputs, namespace, ... }:
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
      ];
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { inherit inputs namespace; };

        # Import Shared Home-Manager Modules
        sharedModules = [
          (
            { osConfig, ... }:
            {
              home.stateVersion = osConfig.system.stateVersion;
            }
          )
          inputs.self.modules.homeManager.desktop
        ];
      };
    };
}
