# Home Manager Layer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire the home-manager layer onto the existing dendritic NixOS flake — auto-user creation from `homes/`, dual dendritic buckets (NixOS + HM sides per module), and `sharedModules` injection so desktop defaults reach all users automatically.

**Architecture:** `lib/homes.nix` scans `homes/` at eval time, creates bare NixOS users, and injects both `flake.modules.homeManager.desktop` (via `sharedModules`) and the user's personal home files into HM. Desktop feature modules (hyprland.nix, etc.) contribute to both `flake.modules.nixos.desktop` and `flake.modules.homeManager.desktop` in the same file. `osConfig` lets HM modules read NixOS state without circular deps.

**Tech Stack:** flake-parts, import-tree, easy-hosts, home-manager (NixOS module), Stylix, nixpkgs-unstable

---

## File Map

```
Modify:  flake.nix                                         — update shared.modules (add desktop + homes, core→common)
Create:  lib/homes.nix                                     — discover homes/, create NixOS users, wire HM + sharedModules
Modify:  modules/core/nix.nix                              — rename bucket core→common, add nix daemon settings
Modify:  modules/core/boot.nix                             — rename bucket core→common
Create:  modules/desktop/group.nix                         — desktop.enable + desktop.theme + greeter options; pipewire, fonts
Modify:  modules/desktop/environments/hyprland.nix         — rewrite as dual bucket (NixOS + HM side)
Modify:  modules/desktop/greeters/greetd.nix               — fill in greetd service
Modify:  modules/desktop/themes/catppuccinMocha.nix        — rename to catppuccin-mocha.nix, fill in with Stylix
Modify:  flake.nix                                         — add stylix input (done in Task 8)
Create:  homes/simi/default.nix                            — plain HM module, shared across all hosts
Create:  homes/simi@zenko/default.nix                      — zenko-specific HM overrides
Create:  homes/simi@tenko/default.nix                      — tenko-specific HM overrides
Modify:  hosts/x86_64-nixos/zenko/default.nix              — migrate to new option namespace
Modify:  hosts/x86_64-nixos/tenko/default.nix              — migrate to new option namespace
```

---

## Task 1: Rename core→common and update flake.nix shared.modules

**Files:**
- Modify: `modules/core/nix.nix`
- Modify: `modules/core/boot.nix`
- Modify: `flake.nix`

The current code uses `flake.modules.nixos.core`; the spec uses `flake.modules.nixos.common`. Rename the bucket and update `easy-hosts.shared.modules` to include common + desktop + homes (desktop and homes don't exist yet — wiring them now means they become active as soon as the files are created, with no further flake.nix edits needed).

- [ ] **Step 1: Verify current shared.modules**

```bash
nix eval .#nixosConfigurations.zenko.config.nix.settings.experimental-features 2>&1 || true
```

Expected: error or empty — `experimental-features` is not set yet.

- [ ] **Step 2: Update modules/core/nix.nix**

Replace the entire file:

```nix
{ ... }: {
  flake.modules.nixos.common = { lib, ... }: {
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store   = true;
    };
    nixpkgs.config.allowUnfree = true;
  };
}
```

- [ ] **Step 3: Update modules/core/boot.nix**

Replace the entire file:

```nix
{ ... }: {
  flake.modules.nixos.common = { lib, pkgs, ... }: {
    boot.kernelPackages                  = lib.mkDefault pkgs.linuxPackages_latest;
    boot.loader.systemd-boot.enable      = true;
    boot.loader.systemd-boot.editor      = false;
    boot.loader.efi.canTouchEfiVariables = true;
  };
}
```

- [ ] **Step 4: Update flake.nix easy-hosts block**

Find the `easy-hosts` block and replace it:

```nix
easy-hosts = {
  path          = ./hosts;
  autoConstruct = true;
  shared.modules = [
    config.flake.modules.nixos.common
    config.flake.modules.nixos.desktop
    config.flake.modules.nixos.homes
    inputs.disko.nixosModules.disko
  ];
};
```

Note: `desktop` and `homes` buckets don't exist yet — they will default to empty modules until their files are created, so no eval error.

- [ ] **Step 5: Verify common settings land**

```bash
nix eval .#nixosConfigurations.zenko.config.nix.settings.experimental-features
```

Expected: `[ "nix-command" "flakes" ]`

```bash
nix eval .#nixosConfigurations.zenko.config.boot.loader.systemd-boot.enable
```

Expected: `true`

- [ ] **Step 6: Commit**

```bash
git add modules/core/nix.nix modules/core/boot.nix flake.nix
git commit -m "chore: rename nixos bucket core→common, wire desktop+homes into shared.modules"
```

---

## Task 2: Create lib/homes.nix

**Files:**
- Create: `lib/homes.nix`

This is the bridge between `homes/` and NixOS/HM. It scans the directory at eval time, parses the `user@host` naming convention, creates bare NixOS users, and wires HM — including injecting `flake.modules.homeManager.desktop` via `sharedModules`.

The outer `{ lib, inputs, config, ... }:` receives the flake-parts config. The `config.flake.modules.homeManager.desktop` is captured at flake-parts scope (before the NixOS module is built) and passed in as a closure value, so it's always the fully-merged HM desktop bucket regardless of file evaluation order.

- [ ] **Step 1: Verify user does NOT exist yet**

```bash
mkdir -p homes/simi && echo '{ ... }: {}' > homes/simi/default.nix
nix eval .#nixosConfigurations.zenko.config.users.users.simi.isNormalUser 2>&1 || true
```

Expected: error — `simi` not found in users.

- [ ] **Step 2: Create lib/homes.nix**

```nix
{ lib, inputs, config, ... }:
let
  homesPath = ../homes;

  homesDirs =
    if builtins.pathExists homesPath
    then
      builtins.attrNames (
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

  # Captured at flake-parts scope — safe to use inside the NixOS module below.
  hmDesktopModule = config.flake.modules.homeManager.desktop or ({ ... }: { });

  homesNixosModule =
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
  flake.modules.nixos.homes = homesNixosModule;
}
```

- [ ] **Step 3: Verify user is created**

```bash
nix eval .#nixosConfigurations.zenko.config.users.users.simi.isNormalUser
```

Expected: `true`

- [ ] **Step 4: Verify HM is wired**

```bash
nix eval .#nixosConfigurations.zenko.config.home-manager.users.simi.home.username
```

Expected: `"simi"`

- [ ] **Step 5: Verify host-specific home is NOT applied to a wrong host**

```bash
# Create a host-specific entry for tenko only
mkdir -p homes/simi@tenko && echo '{ ... }: {}' > homes/simi@tenko/default.nix
nix eval .#nixosConfigurations.zenko.config.home-manager.users.simi.home.username
```

Expected: still `"simi"` — zenko picks up `homes/simi/` (global) but NOT `homes/simi@tenko/`.

- [ ] **Step 6: Commit**

```bash
git add lib/homes.nix homes/simi/default.nix homes/simi@tenko/default.nix
git commit -m "feat: add homes auto-discovery — presence of homes/<user>/default.nix creates NixOS user"
```

---

## Task 3: Create modules/desktop/group.nix

**Files:**
- Create: `modules/desktop/group.nix`

Defines the three NixOS options (`desktop.enable`, `desktop.theme`, `greeter`) and activates pipewire, fonts, dconf, and system services when `desktop.enable = true`. Nothing in this module self-activates — it waits for a DE module (Hyprland, etc.) to set `desktop.enable = lib.mkDefault true`.

- [ ] **Step 1: Verify option does not exist yet**

```bash
nix eval .#nixosConfigurations.zenko.config.desktop.enable 2>&1 || true
```

Expected: error — option `desktop` not defined.

- [ ] **Step 2: Create modules/desktop/group.nix**

```nix
{ ... }: {
  flake.modules.nixos.desktop =
    { config, lib, pkgs, ... }:
    {
      options = {
        desktop.enable = lib.mkEnableOption "desktop group (pipewire, fonts, dconf, portals)";

        desktop.theme = lib.mkOption {
          type    = lib.types.enum [ null "catppuccin-mocha" ];
          default = null;
          description = "System-wide visual theme via Stylix.";
        };

        greeter = lib.mkOption {
          type    = lib.types.enum [ null "greetd" ];
          default = null;
          description = "Login greeter to enable.";
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

        programs.dconf.enable                  = true;
        services.upower.enable                 = true;
        services.power-profiles-daemon.enable  = true;
        services.gvfs.enable                   = true;
        xdg.portal.enable                      = true;
        xdg.portal.xdgOpenUsePortal            = true;

        environment.systemPackages = with pkgs; [ brightnessctl ];
      };
    };
}
```

- [ ] **Step 3: Verify option exists and is inactive**

```bash
nix eval .#nixosConfigurations.zenko.config.desktop.enable
```

Expected: `false`

```bash
nix eval .#nixosConfigurations.zenko.config.services.pipewire.enable
```

Expected: `false`

- [ ] **Step 4: Commit**

```bash
git add modules/desktop/group.nix
git commit -m "feat: add desktop group module with pipewire, fonts, and cascade options"
```

---

## Task 4: Rewrite modules/desktop/environments/hyprland.nix (dual bucket)

**Files:**
- Modify: `modules/desktop/environments/hyprland.nix`

This is the key dual-bucket module. The NixOS side defines `desktops.hyprland.{enable,settings}` and triggers the desktop group cascade. The HM side reads `osConfig.programs.hyprland.enable` and sets `wayland.windowManager.hyprland.enable = lib.mkDefault true` — so all users on a Hyprland host get HM Hyprland management automatically without writing it in their home file.

- [ ] **Step 1: Verify option does not exist yet**

```bash
nix eval .#nixosConfigurations.zenko.config.desktops.hyprland.enable 2>&1 || true
```

Expected: error — option `desktops` not defined.

- [ ] **Step 2: Rewrite modules/desktop/environments/hyprland.nix**

```nix
{ ... }: {
  # ── NixOS side ────────────────────────────────────────────────────────────
  flake.modules.nixos.desktop =
    { config, lib, ... }:
    {
      options.desktops.hyprland = {
        enable = lib.mkEnableOption "Hyprland (portals, polkit, UWSM)";

        settings = lib.mkOption {
          type        = lib.types.attrs;
          default     = { };
          description = ''
            Host-level Hyprland defaults (keyboard layout, input devices).
            User-level settings live in home-manager and merge on top.
          '';
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

  # ── HM side — injected into all users via sharedModules ───────────────────
  flake.modules.homeManager.desktop =
    { osConfig, lib, ... }:
    {
      wayland.windowManager.hyprland = {
        enable        = lib.mkDefault osConfig.programs.hyprland.enable;
        systemd.enable = lib.mkDefault true;
      };
    };
}
```

- [ ] **Step 3: Temporarily enable Hyprland in zenko to test the cascade**

In `hosts/x86_64-nixos/zenko/default.nix`, add one line (keep everything else):

```nix
desktops.hyprland.enable = true;
```

- [ ] **Step 4: Verify the NixOS cascade fires**

```bash
nix eval .#nixosConfigurations.zenko.config.desktops.hyprland.enable
```

Expected: `true`

```bash
nix eval .#nixosConfigurations.zenko.config.desktop.enable
```

Expected: `true` (set automatically by Hyprland, not explicitly)

```bash
nix eval .#nixosConfigurations.zenko.config.services.pipewire.enable
```

Expected: `true` (desktop group activated by cascade)

```bash
nix eval .#nixosConfigurations.zenko.config.programs.hyprland.enable
```

Expected: `true`

- [ ] **Step 5: Verify HM side is injected into simi**

```bash
nix eval .#nixosConfigurations.zenko.config.home-manager.users.simi.wayland.windowManager.hyprland.enable
```

Expected: `true` (from sharedModules, not from homes/simi/default.nix)

- [ ] **Step 6: Remove the temporary line from zenko/default.nix**

(Will be set properly in Task 9 when migrating the host.)

- [ ] **Step 7: Commit**

```bash
git add modules/desktop/environments/hyprland.nix
git commit -m "feat: rewrite Hyprland module as dual bucket (NixOS cascade + HM sharedModules injection)"
```

---

## Task 5: Fill modules/desktop/greeters/greetd.nix

**Files:**
- Modify: `modules/desktop/greeters/greetd.nix`

Activates greetd when `greeter = "greetd"` is set. Contributes to `flake.modules.nixos.desktop`.

- [ ] **Step 1: Verify greeter option exists but greetd is off**

```bash
nix eval .#nixosConfigurations.zenko.config.greeter
```

Expected: `null`

- [ ] **Step 2: Rewrite modules/desktop/greeters/greetd.nix**

```nix
{ ... }: {
  flake.modules.nixos.desktop =
    { config, lib, pkgs, ... }:
    {
      config = lib.mkIf (config.greeter == "greetd") {
        services.greetd = {
          enable   = true;
          settings.default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
            user    = "greeter";
          };
        };
      };
    };
}
```

- [ ] **Step 3: Temporarily test greetd activation**

Add `greeter = "greetd";` to `hosts/x86_64-nixos/zenko/default.nix` temporarily.

```bash
nix eval .#nixosConfigurations.zenko.config.services.greetd.enable
```

Expected: `true`

- [ ] **Step 4: Remove the temporary line**

- [ ] **Step 5: Commit**

```bash
git add modules/desktop/greeters/greetd.nix
git commit -m "feat: add greetd greeter module"
```

---

## Task 6: Add stylix input and fill catppuccin-mocha theme

**Files:**
- Modify: `flake.nix` — add stylix input
- Modify: `modules/desktop/themes/catppuccinMocha.nix` — rename and fill in

Stylix provides system-wide theming. It must be imported as a NixOS module inside the deferredModule so its options are available in the NixOS evaluation. The theme activates only when `desktop.theme = "catppuccin-mocha"`.

- [ ] **Step 1: Add stylix input to flake.nix**

In the `inputs` block, add:

```nix
stylix = {
  url = "github:danth/stylix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

- [ ] **Step 2: Rename and rewrite the theme file**

Delete `modules/desktop/themes/catppuccinMocha.nix` and create `modules/desktop/themes/catppuccin-mocha.nix`:

```bash
rm modules/desktop/themes/catppuccinMocha.nix
```

```nix
# modules/desktop/themes/catppuccin-mocha.nix
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

          override = {
            base00 = "181825";
            base01 = "11111b";
            base02 = "313244";
          };

          opacity.desktop = 0.72;
          opacity.popups  = 0.72;

          image = pkgs.fetchurl {
            url    = "https://raw.githubusercontent.com/catppuccin/wallpapers/main/minimalistic/catppuccin-mocha.png";
            sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          };

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

> **Note:** The wallpaper `sha256` is a placeholder. Run `nix-prefetch-url <url>` to get the real hash, or replace with a local path: `image = ./wallpaper.png;` after placing an image in the repo.

- [ ] **Step 3: Temporarily test theme activation**

Add `desktop.theme = "catppuccin-mocha";` and `desktops.hyprland.enable = true;` to zenko temporarily.

```bash
nix eval .#nixosConfigurations.zenko.config.stylix.enable
```

Expected: `true`

- [ ] **Step 4: Remove temporary lines**

- [ ] **Step 5: Commit**

```bash
git add flake.nix flake.lock modules/desktop/themes/catppuccin-mocha.nix
git rm modules/desktop/themes/catppuccinMocha.nix
git commit -m "feat: add catppuccin-mocha Stylix theme module, add stylix input"
```

---

## Task 7: Create homes/simi/

**Files:**
- Modify: `homes/simi/default.nix` — fill in shared base (was empty stub from Task 2)
- Create: `homes/simi@zenko/default.nix`
- Create: `homes/simi@tenko/default.nix` — already created as stub in Task 2, fill in

The home files are plain HM modules — functions that receive standard HM args (`pkgs`, `lib`, `config`, `osConfig`, etc.). No flake-parts wrapper. The Hyprland `enable = true` is already injected via `sharedModules` — these files only need personal config on top.

- [ ] **Step 1: Fill in homes/simi/default.nix**

```nix
{ pkgs, ... }: {
  programs.git = {
    enable    = true;
    userName  = "Zenko";
    userEmail = "simi.git@outlook.com";
  };

  programs.fish = {
    enable      = true;
    shellInit   = "set -U fish_greeting \"\"";
  };

  home.packages = with pkgs; [
    btop
    fastfetch
  ];
}
```

- [ ] **Step 2: Create homes/simi@zenko/default.nix**

```nix
{ ... }: {
  wayland.windowManager.hyprland.settings = {
    input = {
      kb_layout = "pt";
    };
    device = [
      {
        name           = "foca0001:00-2808:0106-touchpad";
        natural_scroll = true;
      }
    ];
  };
}
```

- [ ] **Step 3: Fill in homes/simi@tenko/default.nix**

```nix
{ ... }: {
  wayland.windowManager.hyprland.settings = {
    input = {
      kb_layout  = "us";
      kb_variant = "intl";
    };
    device = [
      {
        name          = "compx-atk-a9-ultra-1";
        accel_profile = "flat";
        sensitivity   = -0.25;
      }
      {
        name          = "compx-atk-mouse-8k-dongle-mouse";
        accel_profile = "flat";
        sensitivity   = -0.25;
      }
    ];
  };
}
```

- [ ] **Step 4: Verify git config lands for simi on zenko**

```bash
nix eval .#nixosConfigurations.zenko.config.home-manager.users.simi.programs.git.userName
```

Expected: `"Zenko"`

- [ ] **Step 5: Verify zenko-specific Hyprland settings land**

```bash
# First temporarily re-enable hyprland in zenko
# Add desktops.hyprland.enable = true; to zenko/default.nix

nix eval .#nixosConfigurations.zenko.config.home-manager.users.simi.wayland.windowManager.hyprland.settings --json
```

Expected: attrset containing `input.kb_layout = "pt"` and the touchpad device entry.

- [ ] **Step 6: Verify tenko-specific settings do NOT appear on zenko**

```bash
nix eval .#nixosConfigurations.zenko.config.home-manager.users.simi.wayland.windowManager.hyprland.settings.input.kb_layout
```

Expected: `"pt"` — not `"us"` (tenko's layout doesn't leak into zenko).

- [ ] **Step 7: Remove temporary hyprland.enable line from zenko**

- [ ] **Step 8: Commit**

```bash
git add homes/simi/default.nix homes/simi@zenko/default.nix homes/simi@tenko/default.nix
git commit -m "feat: add simi home config (shared base + per-host Hyprland overrides)"
```

---

## Task 8: Migrate hosts/x86_64-nixos/zenko/default.nix

**Files:**
- Modify: `hosts/x86_64-nixos/zenko/default.nix`

Replace the commented-out `main.*` block with the new option namespace. Remove boot/Plymouth config that now lives in core modules. Keep only what is genuinely zenko-specific.

- [ ] **Step 1: Verify current zenko evaluates**

```bash
nix eval .#nixosConfigurations.zenko.config.system.stateVersion
```

Expected: `"25.11"` (proves zenko evaluates at all)

- [ ] **Step 2: Rewrite hosts/x86_64-nixos/zenko/default.nix**

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
    shell       = pkgs.fish;
    extraGroups = [ "wheel" "video" "input" "networkmanager" ];
    hashedPassword = "$y$j9T$tjs435fHbjQ.5SGhfWQP2.$eY6O.M606bYPymg/JU3rFNEWWLkIBba4JYAaU0gEmG4";
  };

  nix.settings.secret-key-files = [ "/etc/nix/signing-key.sec" ];

  time.timeZone      = "Europe/Lisbon";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap     = "pt-latin1";

  zramSwap.enable = true;

  system.stateVersion = "25.11";
}
```

> **Note:** `pkgs.main.bootTheme` requires the custom packages overlay to be set up. If it isn't yet, comment out the `boot.plymouth` block until the overlay is wired.

- [ ] **Step 3: Verify zenko cascade works end-to-end**

```bash
nix eval .#nixosConfigurations.zenko.config.desktops.hyprland.enable
```
Expected: `true`

```bash
nix eval .#nixosConfigurations.zenko.config.desktop.enable
```
Expected: `true`

```bash
nix eval .#nixosConfigurations.zenko.config.services.pipewire.enable
```
Expected: `true`

```bash
nix eval .#nixosConfigurations.zenko.config.services.greetd.enable
```
Expected: `true`

```bash
nix eval .#nixosConfigurations.zenko.config.users.users.simi.isNormalUser
```
Expected: `true`

- [ ] **Step 4: Commit**

```bash
git add hosts/x86_64-nixos/zenko/default.nix
git commit -m "chore: migrate zenko to new dendritic option namespace"
```

---

## Task 9: Migrate hosts/x86_64-nixos/tenko/default.nix

**Files:**
- Modify: `hosts/x86_64-nixos/tenko/default.nix`

Same pattern as zenko. tenko has no asusd, no signing key, has ollama enabled, and uses US-intl keyboard.

- [ ] **Step 1: Rewrite hosts/x86_64-nixos/tenko/default.nix**

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
    shell       = pkgs.fish;
    extraGroups = [ "wheel" "video" "input" "networkmanager" ];
    hashedPassword = "$y$j9T$tjs435fHbjQ.5SGhfWQP2.$eY6O.M606bYPymg/JU3rFNEWWLkIBba4JYAaU0gEmG4";
  };

  time.timeZone      = "Europe/Lisbon";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap     = "us-intl";

  zramSwap.enable = true;

  system.stateVersion = "25.11";
}
```

- [ ] **Step 2: Verify tenko evaluates with correct settings**

```bash
nix eval .#nixosConfigurations.tenko.config.desktops.hyprland.enable
```
Expected: `true`

```bash
nix eval .#nixosConfigurations.tenko.config.services.ollama.enable
```
Expected: `true`

```bash
nix eval .#nixosConfigurations.tenko.config.users.users.simi.isNormalUser
```
Expected: `true`

- [ ] **Step 3: Commit**

```bash
git add hosts/x86_64-nixos/tenko/default.nix
git commit -m "chore: migrate tenko to new dendritic option namespace"
```

---

## Task 10: Full verification

- [ ] **Step 1: Check flake evaluates cleanly**

```bash
nix flake check 2>&1 | head -50
```

Expected: no errors.

- [ ] **Step 2: Verify simi exists on both hosts**

```bash
nix eval .#nixosConfigurations.zenko.config.users.users.simi.isNormalUser
nix eval .#nixosConfigurations.tenko.config.users.users.simi.isNormalUser
```

Both expected: `true`

- [ ] **Step 3: Verify HM is active on both hosts**

```bash
nix eval .#nixosConfigurations.zenko.config.home-manager.users.simi.programs.git.enable
nix eval .#nixosConfigurations.tenko.config.home-manager.users.simi.programs.git.enable
```

Both expected: `true`

- [ ] **Step 4: Verify HM Hyprland is injected via sharedModules on both hosts**

```bash
nix eval .#nixosConfigurations.zenko.config.home-manager.users.simi.wayland.windowManager.hyprland.enable
nix eval .#nixosConfigurations.tenko.config.home-manager.users.simi.wayland.windowManager.hyprland.enable
```

Both expected: `true`

- [ ] **Step 5: Verify per-host HM settings are isolated**

```bash
nix eval .#nixosConfigurations.zenko.config.home-manager.users.simi.wayland.windowManager.hyprland.settings.input.kb_layout
```
Expected: `"pt"`

```bash
nix eval .#nixosConfigurations.tenko.config.home-manager.users.simi.wayland.windowManager.hyprland.settings.input.kb_layout
```
Expected: `"us"`

- [ ] **Step 6: Forker smoke test — add alice, verify auto-creation**

```bash
mkdir -p homes/alice
echo '{ pkgs, ... }: { home.packages = [ pkgs.neovim ]; }' > homes/alice/default.nix
nix eval .#nixosConfigurations.zenko.config.users.users.alice.isNormalUser
```

Expected: `true`

```bash
nix eval .#nixosConfigurations.tenko.config.users.users.alice.isNormalUser
```

Expected: `true` (global home, appears on all hosts)

```bash
rm -rf homes/alice
```

- [ ] **Step 7: Try building zenko derivation**

```bash
nix build .#nixosConfigurations.zenko.config.system.build.toplevel --no-link --show-trace 2>&1 | tail -20
```

Expected: build succeeds or fails only on missing `pkgs.main.bootTheme` (packages overlay not yet set up — acceptable).

- [ ] **Step 8: Final commit**

```bash
git add .
git commit -m "chore: full home-manager layer verification complete"
```

---

## Forker Checklist

After all tasks pass, validate the fork experience:

| Action | Command | Expected |
|---|---|---|
| Drop `homes/alice/default.nix` | `nix eval .#nixosConfigurations.zenko.config.users.users.alice.isNormalUser` | `true` |
| Host adds `users.users.alice.shell = pkgs.fish` | `nix eval ...alice.shell` | `/nix/store/.../fish` |
| Alice opts out of Hyprland HM | Add `wayland.windowManager.hyprland.enable = lib.mkForce false;` to her home | Overrides sharedModules |
| New host with no homes entries | `users.users` on that host | Only `root` — no simi, no alice |
