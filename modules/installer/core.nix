{
  flake.modules.nixos.installer =
    {
      inputs,
      lib,
      pkgs,
      ...
    }:
    {
      boot.blacklistedKernelModules = [ "nouveau" ];

      environment = {
        etc."nixos".source = inputs.self;
        systemPackages = with pkgs; [
          git
          vim
        ];
      };

      nix.settings = {
        trusted-users = [
          "root"
          "nixos"
        ];
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
      nixpkgs.config.allowUnfree = true;

      services.getty.autologinUser = lib.mkDefault "nixos";
      services.openssh = {
        enable = true;
        openFirewall = true;
        settings = {
          PermitRootLogin = "yes";
          PasswordAuthentication = true;
          KbdInteractiveAuthentication = true;
        };
      };
      users = {
        motd = ''
          ______________________________________________________
          |_|NixQuick Installer|________________________________|
          |                                                     |
          | Welcome to the NixQuick Installer!                  |
          |                                                     |
          | - SSH is enabled by default.                        |
          | - The password for 'nixos' and 'root' is 'nixquick'.|
          | - To connect to a Network, "nmtui" is available.    |
          |_____________________________________________________|
        '';
        users = {
          nixos = {
            isNormalUser = true;
            createHome = true;
            home = "/home/nixos";
            description = "NixOS Installer User";
            extraGroups = [ "wheel" ];
            password = "nixquick";
          };
          root.password = "nixquick";
        };
      };
    };
}
