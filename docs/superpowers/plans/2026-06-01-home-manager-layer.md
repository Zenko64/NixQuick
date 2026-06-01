# Home Manager Layer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the home-manager layer — homes auto-discovery, desktop module options, Hyprland dual bucket, greeter, theme, personal home files, and host migrations.

**Architecture:** `lib/homes.nix` scans `homes/` and wires HM + NixOS users. Desktop modules contribute to `flake.modules.nixos.desktop` (NixOS side) and `flake.modules.homeManager.desktop` (HM side, injected to all users via `sharedModules`). `osConfig` lets HM modules read NixOS state.

**Tech Stack:** flake-parts, import-tree, easy-hosts, home-manager (NixOS module), Stylix, nixpkgs-unstable

**Current state:** `flake.nix` is already correct — `core`, `desktop`, `homes` all wired in `shared.modules`. `modules/core/` is done. Remaining work starts at `lib/homes.nix`.

---

## File Map

```
Create:  lib/homes.nix
Create:  modules/desktop/group.nix
Rewrite: modules/desktop/environments/hyprland.nix
Fill:    modules/desktop/greeters/greetd.nix
Fill:    modules/desktop/themes/catppuccinMocha.nix        (add stylix input to flake.nix)
Create:  homes/simi/default.nix
Create:  homes/simi@zenko/default.nix
Create:  homes/simi@tenko/default.nix
Migrate: hosts/x86_64-nixos/zenko/default.nix
Migrate: hosts/x86_64-nixos/tenko/default.nix
```

---

## Task 1: lib/homes.nix

Scans `homes/` at eval time. Folder + `default.nix` = user created. Naming: `simi` → all hosts, `simi@zenko` → zenko only. Creates bare NixOS user, wires HM with `sharedModules`.

The outer `{ lib, inputs, config, ... }` is flake-parts scope — `config.flake.modules.homeManager.desktop` is captured here before entering the NixOS module, so the HM bucket is always the fully-merged value.

- [ ] **Create lib/homes.nix**

```nix
{ lib, inputs, config, ... }:
let
  homesPath = ../homes;

  homesDirs =
    if builtins.pathExists homesPath
    then builtins.attrNames (
      lib.filterAttrs (_: t: t == "directory") (builtins.readDir homesPath)
    )
    else [ ];

  parseEntry = name:
    let parts = lib.splitString "@" name;
    in {
      user = builtins.head parts;
      host = if builtins.length parts > 1 then builtins.elemAt parts 1 else null;
      path = homesPath + "/${name}";
    };

  entries = lib.filter
    (e: builtins.pathExists (e.path + "/default.nix"))
    (map parseEntry homesDirs);

  entriesForHost = hostname:
    lib.filter (e: e.host == null || e.host == hostname) entries;

  usersForHost = hostname:
    lib.unique (map (e: e.user) (entriesForHost hostname));

  importsForUser = hostname: user:
    map (e: e.path + "/default.nix") (
      lib.filter (e: e.user == user) (entriesForHost hostname)
    );

  hmDesktopModule = config.flake.modules.homeManager.desktop or ({ ... }: { });

  homesModule =
    { config, lib, ... }:
    let
      hostname = config.networking.hostName;
      users    = usersForHost hostname;
    in
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      home-manager = {
        useGlobalPkgs   = true;
        useUserPackages = true;
        sharedModules   = [ hmDesktopModule ];
        users           = lib.genAttrs users (user: {
          home.username      = user;
          home.homeDirectory = "/home/${user}";
          home.stateVersion  = "25.11";
          imports            = importsForUser hostname user;
        });
      };

      users.users = lib.genAttrs users (_: {
        isNormalUser = true;
      });
    };
in
{
  flake.modules.nixos.homes = homesModule;
}
```

- [ ] **Verify** — create a stub first, check user appears:

```bash
mkdir -p homes/simi && echo '{ ... }: {}' > homes/simi/default.nix
nix eval .#nixosConfigurations.zenko.config.users.users.simi.isNormalUser
# expected: true
```

- [ ] **Commit**

```bash
git add lib/homes.nix homes/simi/default.nix
git commit -m "feat: homes auto-discovery — presence of homes/<user>/default.nix creates NixOS user"
```

---

## Task 2: modules/desktop/group.nix

Defines the three NixOS options that the rest of the desktop layer reads. Nothing self-activates — Hyprland sets `desktop.enable = lib.mkDefault true` as a side effect, which fires this module.

- [ ] **Create modules/desktop/group.nix**

```nix
{ ... }: {
  flake.modules.nixos.desktop =
    { config, lib, pkgs, ... }:
    {
      options = {
        desktop.enable = lib.mkEnableOption "desktop group";

        desktop.theme = lib.mkOption {
          type    = lib.types.enum [ null "catppuccin-mocha" ];
          default = null;
        };

        greeter = lib.mkOption {
          type    = lib.types.enum [ null "greetd" ];
          default = null;
        };
      };

      config = lib.mkIf config.desktop.enable {
        services.pipewire = {
          enable             = true;
          pulse.enable       = true;
          wireplumber.enable = true;
        };

        fonts.packages = with pkgs; [
          geist-font
          nerd-fonts.geist-mono
          noto-fonts-color-emoji
        ];
        fonts.fontconfig.defaultFonts = {
          sansSerif = [ "Geist" ];
          monospace = [ "GeistMono Nerd Font" ];
          emoji     = [ "Noto Color Emoji" ];
        };

        programs.dconf.enable                 = true;
        services.upower.enable                = true;
        services.power-profiles-daemon.enable = true;
        services.gvfs.enable                  = true;
        xdg.portal.enable                     = true;
        xdg.portal.xdgOpenUsePortal           = true;

        environment.systemPackages = with pkgs; [ brightnessctl ];
      };
    };
}
```

- [ ] **Verify**

```bash
nix eval .#nixosConfigurations.zenko.config.desktop.enable
# expected: false  (option exists, nothing enabled yet)
```

- [ ] **Commit**

```bash
git add modules/desktop/group.nix
git commit -m "feat: desktop group module — pipewire, fonts, portals behind desktop.enable"
```

---

## Task 3: Rewrite modules/desktop/environments/hyprland.nix

Current file uses wrong bucket name (`desktops` vs `desktop`) and the broken old namespace pattern. Replace entirely with the dual bucket.

NixOS side: defines `desktops.hyprland.{enable,settings}` and triggers the cascade.
HM side: enables `wayland.windowManager.hyprland` for all users on hosts where Hyprland is active, using `osConfig` to read NixOS state.

- [ ] **Rewrite modules/desktop/environments/hyprland.nix**

```nix
{ ... }: {
  # NixOS side
  flake.modules.nixos.desktop =
    { config, lib, ... }:
    {
      options.desktops.hyprland = {
        enable = lib.mkEnableOption "Hyprland";

        settings = lib.mkOption {
          type        = lib.types.attrs;
          default     = { };
          description = "Host-level Hyprland config (keyboard, input devices). User settings live in HM and merge on top.";
        };
      };

      config = lib.mkIf config.desktops.hyprland.enable {
        desktop.enable = lib.mkDefault true;

        programs.hyprland = {
          enable   = true;
          withUWSM = true;
        };
      };
    };

  # HM side — injected into all users via sharedModules
  flake.modules.homeManager.desktop =
    { osConfig, lib, ... }:
    {
      wayland.windowManager.hyprland = {
        enable         = lib.mkDefault osConfig.programs.hyprland.enable;
        systemd.enable = lib.mkDefault true;
      };
    };
}
```

- [ ] **Verify cascade** — temporarily add `desktops.hyprland.enable = true;` to `hosts/x86_64-nixos/zenko/default.nix`:

```bash
nix eval .#nixosConfigurations.zenko.config.desktop.enable      # true
nix eval .#nixosConfigurations.zenko.config.services.pipewire.enable  # true
nix eval .#nixosConfigurations.zenko.config.programs.hyprland.enable  # true
nix eval .#nixosConfigurations.zenko.config.home-manager.users.simi.wayland.windowManager.hyprland.enable  # true
```

- [ ] **Remove the temporary line** from zenko/default.nix

- [ ] **Commit**

```bash
git add modules/desktop/environments/hyprland.nix
git commit -m "feat: Hyprland dual bucket — NixOS cascade + HM injection via sharedModules"
```

---

## Task 4: modules/desktop/greeters/greetd.nix

Fires when `greeter = "greetd"`. No options to define — reads the option defined in group.nix.

- [ ] **Fill modules/desktop/greeters/greetd.nix**

```nix
{ ... }: {
  flake.modules.nixos.desktop =
    { config, lib, pkgs, ... }:
    {
      config = lib.mkIf (config.greeter == "greetd") {
        services.greetd = {
          enable = true;
          settings.default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
            user    = "greeter";
          };
        };
      };
    };
}
```

- [ ] **Commit**

```bash
git add modules/desktop/greeters/greetd.nix
git commit -m "feat: greetd greeter module"
```

---

## Task 5: modules/desktop/themes/catppuccinMocha.nix + stylix input

Stylix is imported inside the deferredModule (not at flake level) so its NixOS options are available during system evaluation. The theme fires when `desktop.theme = "catppuccin-mocha"`.

- [ ] **Add stylix input to flake.nix**

In the `inputs` block:

```nix
stylix = {
  url = "github:danth/stylix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Then `nix flake lock`.

- [ ] **Fill modules/desktop/themes/catppuccinMocha.nix**

```nix
{ inputs, ... }: {
  flake.modules.nixos.desktop =
    { config, lib, pkgs, ... }:
    {
      imports = [ inputs.stylix.nixosModules.stylix ];

      config = lib.mkIf (config.desktop.theme == "catppuccin-mocha") {
        stylix = {
          enable       = true;
          base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
          polarity     = "dark";

          cursor = {
            package = pkgs.nordzy-cursor-theme;
            name    = "Nordzy-catppuccin-mocha-sky";
            size    = 24;
          };

          fonts = {
            monospace = { package = pkgs.nerd-fonts.geist-mono; name = "GeistMono Nerd Font"; };
            sansSerif = { package = pkgs.geist-font;            name = "Geist"; };
            serif     = { package = pkgs.geist-font;            name = "Geist"; };
            emoji     = { package = pkgs.noto-fonts-color-emoji; name = "Noto Color Emoji"; };
            sizes     = { applications = 11; terminal = 12; desktop = 11; popups = 11; };
          };

          targets.plymouth.enable = false;
          targets.qt.enable       = false;
        };
      };
    };
}
```

> `stylix` requires a `stylix.image` to be set — add a wallpaper either as a path in the repo or fetched via `pkgs.fetchurl`. Without it, evaluation will error.

- [ ] **Commit**

```bash
git add flake.nix flake.lock modules/desktop/themes/catppuccinMocha.nix
git commit -m "feat: catppuccin-mocha Stylix theme module"
```

---

## Task 6: homes/simi/

Three files. Plain HM modules — no flake-parts wrapper. `wayland.windowManager.hyprland.enable` is already injected by `sharedModules`; these files only add personal config and per-host settings on top.

- [ ] **Fill homes/simi/default.nix** (shared across all hosts)

```nix
{ pkgs, ... }: {
  programs.git = {
    enable    = true;
    userName  = "Zenko";
    userEmail = "simi.git@outlook.com";
  };

  programs.fish = {
    enable    = true;
    shellInit = "set -U fish_greeting \"\"";
  };

  home.packages = with pkgs; [
    btop
    fastfetch
  ];
}
```

- [ ] **Create homes/simi@zenko/default.nix**

```nix
{ ... }: {
  wayland.windowManager.hyprland.settings = {
    input.kb_layout = "pt";
    device = [{
      name           = "foca0001:00-2808:0106-touchpad";
      natural_scroll = true;
    }];
  };
}
```

- [ ] **Create homes/simi@tenko/default.nix**

```nix
{ ... }: {
  wayland.windowManager.hyprland.settings = {
    input.kb_layout  = "us";
    input.kb_variant = "intl";
    device = [
      { name = "compx-atk-a9-ultra-1";           accel_profile = "flat"; sensitivity = -0.25; }
      { name = "compx-atk-mouse-8k-dongle-mouse"; accel_profile = "flat"; sensitivity = -0.25; }
    ];
  };
}
```

- [ ] **Commit**

```bash
git add homes/simi/default.nix homes/simi@zenko/default.nix homes/simi@tenko/default.nix
git commit -m "feat: simi home config — shared base + per-host Hyprland input overrides"
```

---

## Task 7: Migrate hosts/x86_64-nixos/zenko/default.nix

Remove the commented-out `main.*` block. Use new option names. Keep only zenko-specific config.

- [ ] **Rewrite hosts/x86_64-nixos/zenko/default.nix**

```nix
{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./gpu.nix
    ./networks.nix
  ];

  desktops.hyprland.enable = true;
  greeter                  = "greetd";
  desktop.theme            = "catppuccin-mocha";

  boot.loader.systemd-boot.windows."00-windows" = {
    title           = "Windows";
    efiDeviceHandle = "FS0";
    sortKey         = "00";
  };

  boot.plymouth = {
    enable        = true;
    theme         = "bootTheme";
    themePackages = [ pkgs.main.bootTheme ];
  };

  programs.nix-ld.enable  = true;
  programs.steam.enable   = true;
  services.flatpak.enable = true;
  services.asusd.enable   = true;

  services.ollama = {
    enable  = false;
    package = pkgs.ollama-cuda;
  };

  users.users.simi = {
    shell          = pkgs.fish;
    extraGroups    = [ "wheel" "video" "input" "networkmanager" ];
    hashedPassword = "$y$j9T$tjs435fHbjQ.5SGhfWQP2.$eY6O.M606bYPymg/JU3rFNEWWLkIBba4JYAaU0gEmG4";
  };

  nix.settings.secret-key-files = [ "/etc/nix/signing-key.sec" ];

  time.timeZone      = "Europe/Lisbon";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap     = "pt-latin1";

  system.stateVersion = "25.11";
}
```

> `pkgs.main.bootTheme` requires the custom packages overlay. Comment it out if not set up yet.

- [ ] **Commit**

```bash
git add hosts/x86_64-nixos/zenko/default.nix
git commit -m "chore: migrate zenko to new option namespace"
```

---

## Task 8: Migrate hosts/x86_64-nixos/tenko/default.nix

- [ ] **Rewrite hosts/x86_64-nixos/tenko/default.nix**

```nix
{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./gpu.nix
    ./networks.nix
  ];

  desktops.hyprland.enable = true;
  greeter                  = "greetd";
  desktop.theme            = "catppuccin-mocha";

  boot.loader.systemd-boot.windows."00-windows" = {
    title           = "Windows";
    efiDeviceHandle = "FS0";
    sortKey         = "00";
  };

  boot.plymouth = {
    enable        = true;
    theme         = "bootTheme";
    themePackages = [ pkgs.main.bootTheme ];
  };

  programs.nix-ld.enable  = true;
  programs.steam.enable   = true;
  services.flatpak.enable = true;

  services.ollama = {
    enable  = true;
    package = pkgs.ollama-cuda;
  };

  users.users.simi = {
    shell          = pkgs.fish;
    extraGroups    = [ "wheel" "video" "input" "networkmanager" ];
    hashedPassword = "$y$j9T$tjs435fHbjQ.5SGhfWQP2.$eY6O.M606bYPymg/JU3rFNEWWLkIBba4JYAaU0gEmG4";
  };

  time.timeZone      = "Europe/Lisbon";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap     = "us-intl";

  system.stateVersion = "25.11";
}
```

- [ ] **Commit**

```bash
git add hosts/x86_64-nixos/tenko/default.nix
git commit -m "chore: migrate tenko to new option namespace"
```

---

## Final verification

```bash
# Users exist on both hosts
nix eval .#nixosConfigurations.zenko.config.users.users.simi.isNormalUser
nix eval .#nixosConfigurations.tenko.config.users.users.simi.isNormalUser

# Cascade: Hyprland → desktop.enable → pipewire
nix eval .#nixosConfigurations.zenko.config.services.pipewire.enable

# HM wired
nix eval .#nixosConfigurations.zenko.config.home-manager.users.simi.programs.git.enable

# Per-host HM isolation
nix eval .#nixosConfigurations.zenko.config.home-manager.users.simi.wayland.windowManager.hyprland.settings.input.kb_layout
# "pt"
nix eval .#nixosConfigurations.tenko.config.home-manager.users.simi.wayland.windowManager.hyprland.settings.input.kb_layout
# "us"
```
