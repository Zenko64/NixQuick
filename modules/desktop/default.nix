{
  flake.modules.nixos.desktop =
    {
      pkgs,
      ...
    }:
    {
      # System Dependencies
      networking.networkmanager.enable = true;
      programs = {
        dconf.enable = true;
        uwsm.enable = true;
      };

      environment.systemPackages = with pkgs; [
        brightnessctl
      ];

      environment.variables = {
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
      };

      # System Fonts
      fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
      ];
    };

  flake.modules.homeManager.desktop =
    {
      pkgs,
      config,
      ...
    }:
    {
      home.packages = with pkgs; [
        pwvucontrol
      ];

      xdg = {
        configFile."uwsm/env".source =
          "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
        mime.enable = true;
        userDirs = {
          enable = true;
          createDirectories = true;
          setSessionVariables = false;
        };
      };
    };
}
