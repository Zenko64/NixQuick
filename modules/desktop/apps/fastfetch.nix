# Fastfetch (Home Manager)
#
# Contributes to the shared desktop home module, so every desktop home gets it.
# The logo points at an ASCII art file that must exist at the referenced path,
# otherwise the logo renders blank. See the note next to logo.source below.
{
  flake.modules.homeManager.desktop = {
    programs.fastfetch = {
      enable = true;

      settings = {
        "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

        logo = {
          # This file is not managed by Nix yet. Drop the art here, or swap this for a
          # builtin (source = "nixos"; type = "builtin";) or a Nix-managed file.
          source = "~/.config/fastfetch/ascii/arch.txt";
          height = 22;
          padding.bottom = 1;
        };

        display.separator = " ";

        modules = [
          { key = "╭───────────╮"; type = "custom"; }
          { key = "│  user    │"; type = "title"; format = "{user-name}"; }
          { key = "│ 󰇅 hname   │"; type = "title"; format = "{host-name}"; }
          { key = "│ 󰅐 uptime  │"; type = "uptime"; }
          { key = "│  distro  │"; type = "os"; }
          { key = "│  kernel  │"; type = "kernel"; }
          { key = "│  wm      │"; type = "wm"; }
          { key = "│  term    │"; type = "terminal"; }
          { key = "│  shell   │"; type = "shell"; }
          { key = "│ 󰍛 cpu     │"; type = "cpu"; showPeCoreCount = true; }
          { key = "│ 󰉉 disk    │"; type = "disk"; folders = "/"; }
          { key = "│  memory  │"; type = "memory"; }
          { key = "├───────────┤"; type = "custom"; }
          { key = "│ PC        │"; type = "host"; format = "{5} {1} ({2})"; }
          { key = "│ ├ 󰢮 gpu   │"; type = "gpu"; format = "{1} {2} @ {12}"; }
          { key = "│ ├ 󰓡 swap  │"; type = "swap"; }
          { key = "│ ├  disp  │"; type = "monitor"; format = "{1} px @ {2} Hz - {3} mm ({4} inches, {5} pp)"; }
          {
            key = "│ └  dtime │";
            type = "command";
            text = "birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days";
          }
          { key = "│  colors  │"; type = "colors"; symbol = "circle"; }
          { key = "╰───────────╯"; type = "custom"; }
        ];
      };
    };
  };
}
