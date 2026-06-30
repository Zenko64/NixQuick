{ nixquick, ... }:
nixquick.mkTheme {
  themeName = "tokyo-night-light";
  stylixConfig = { pkgs, ... }: {
    stylix = {
      enable = true;
      polarity = "light";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-light.yaml";
      opacity = {
        applications = 0.85;
        desktop = 0.875;
        popups = 0.9;
        terminal = 0.85;
      };
      cursor = {
        package = pkgs.nordzy-cursor-theme;
        name = "Nordzy-catppuccin-latte-sky";
        size = 24;
      };
      icons = {
        enable = true;
        package = pkgs.nordzy-icon-theme;
        dark = "Nordzy-cyan-dark";
        light = "Nordzy-cyan";
      };
    };
  };
}
