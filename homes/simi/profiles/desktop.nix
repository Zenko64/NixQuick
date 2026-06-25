# Desktop Profile
{
  pkgs,
  ...
}:
{
  local.desktop = {
    theme = "catppuccin-mocha";
    wallpaper = ../wallpapers/Clouds.png;
  };

  home.file.".wallpapers" = {
    source = ../wallpapers;
    recursive = true;
  };

  home.packages = with pkgs; [
    # Desktop Apps
    nautilus
    gnome-software
    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })

    # Development Tools
    claude-code
    devenv

    # Terminal toys
    clock-rs
    cmatrix
    pipes-rs
    spotify
    spicetify-cli
    # Tools
    gotop
  ];

  programs = {
    fish = {
      enable = true;
      plugins = [
        {
          name = "tide";
          src = pkgs.fishPlugins.tide.src;
        }
      ];
    };
    # Desktop Apps
    firefox.enable = true;
    kitty.enable = true;

    neovide.enable = true;
    obsidian.enable = true;
    thunderbird.enable = true;

    vscode = {
      enable = true;
      mutableExtensionsDir = true;
    };

    ncmpcpp = {
      enable = true;
    };

    # Toys
    fastfetch.enable = true;
    cava.enable = true;

    # Devtools
    direnv.enable = true;
    neovim.enable = true;
    git = {
      enable = true;
      settings.user = {
        name = "simi";
        email = "simi.git@outlook.com";
      };
    };
  };

  services.mopidy.enable = true;

  wayland.windowManager.hyprland.settings.bind = [
    "SUPER, T, exec, kitty"
    "SUPER, E, exec, firefox"
  ];
}
