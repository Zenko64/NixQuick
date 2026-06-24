# Desktop Profile
{
  lib,
  pkgs,
  ...
}:
{
  local.desktop = {
    theme = "catppuccin-mocha";
    wallpaper = ../wallpapers/Clouds.png; # Set the wallpaper for this user home
  };

  # Copy the wallpapers directory to the user's home directory, at ~/.wallpapers
  home.file.".wallpapers" = {
    source = ../wallpapers;
    recursive = true;
  };

  # Install useful packages, such as Discord, Spotify, a File Manager, Toys, Devtools
  home.packages = with pkgs; [
    # Desktop Apps
    nautilus
    spotify
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

    # Tools
    gotop
  ];

  programs = {
    fish = {
      # Terminal Shell Configuration
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

    # VSCode Config
    vscode = {
      enable = true;
      mutableExtensionsDir = true;
    };

    ncmpcpp = {
      enable = true;
    };

    # Toys
    cava.enable = true;
    fastfetch.enable = true;

    # Devtools
    direnv.enable = true;
    neovim.enable = true;

    # Git Settings
    git = {
      enable = true;
      settings.user = {
        name = "user";
        email = "user.mail@example.com";
      };
    };
  };

  # Mopidy MPD
  services.mopidy = {
    enable = true;
    extensionPackages = [
      pkgs.mopidy-mpd
      pkgs.mopidy-mpris
    ];
  };

  # Bind Keys To Your Needed Apps Thru The WM's native configuration path.
  wayland.windowManager.hyprland.settings.bind = [
    "SUPER, T, exec, ${lib.getExe pkgs.kitty}" # Lib.getExe gets the executable for the package
    "SUPER, E, exec, ${lib.getExe pkgs.nautilus}"
  ];
}
