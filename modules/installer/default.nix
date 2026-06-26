{
  flake.modules.nixos.installer =
    {
      inputs,
      lib,
      pkgs,
      namespace,
      ...
    }:
    {
      ${namespace}.boot.secureBoot = lib.mkDefault false;
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
      services.openssh = lib.mkDefault {
        enable = true;
        settings = {
          PermitEmptyPasswords = true;
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
          |   You can log-in as "nixos" with an empty password. |
          | - To access a root shell, use "sudo bash".          |
          | - To connect to a Network, "nmtui" is available.    |
          |_____________________________________________________|
        '';
        users = {
          nixos = lib.mkDefault {
            isNormalUser = true;
            description = "NixOS Installer User";
            extraGroups = [ "wheel" ];
            password = "";
          };
          root.password = lib.mkDefault "";
        };
      };
    };
}
