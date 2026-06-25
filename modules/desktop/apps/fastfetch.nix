# Fastfetch Default Configuration
{ ... }:
{
  flake.modules.homeManager.desktop =
    {
      config,
      ...
    }:
    let
      c =
        base: fallback:
        if config.stylix.enable then config.lib.stylix.colors.withHashtag.${base} else fallback;
    in
    {
      programs.fastfetch.settings = {
        display = {
          key.width = 10;
          separator = "";
        };

        logo = {
          source = "nixos_small";
          padding = {
            top = 1;
            left = 1;
          };
        };

        modules = [
          "break"
          {
            type = "command";
            key = " user";
            keyColor = c "base0E" "#ccccff";
            text = "echo $USER@$(hostnamectl hostname)";
          }
          {
            type = "os";
            key = " os";
            keyColor = c "base0E" "#c9cfff";
            format = "{name} {version-id}";
          }
          {
            type = "command";
            key = " kernel";
            keyColor = c "base0D" "#c6d2ff";
            text = "echo $(uname -r | cut -d- -f1) $(uname -m)";
          }
          {
            type = "shell";
            key = "󰞷 shell";
            keyColor = c "base0C" "#c0d9ff";
            format = "{pretty-name}";
          }
          {
            type = "cpu";
            key = " cpu";
            keyColor = c "base0D" "#c1d7ff";
            format = "{name}";
          }
          {
            type = "gpu";
            key = "󰢮 gpu";
            keyColor = c "base0C" "#bedcff";
            format = "{vendor} {name}";
          }
          {
            type = "memory";
            key = " ram";
            keyColor = c "base0C" "#bddeff";
            format = "{used} / {total} ({percentage})";
          }
          {
            type = "disk";
            folders = "/";
            key = "󰉉 ssd";
            keyColor = c "base0B" "#bde0fe";
            format = "{size-used} / {size-total} ({size-percentage})";
          }
          {
            type = "colors";
            symbol = "circle";
          }
          "break"
        ];
      };
    };
}
