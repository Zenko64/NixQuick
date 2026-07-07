<div align="center">
  <p align="center">
    <img src="https://raw.githubusercontent.com/Zenko64/NixQuick/refs/heads/main/_assets/logo.svg" width="128" alt="NixQuick Logo">
  </p>
  <h1>NixQuick</h1>

  <p><i>"Achieve a beautiful NixOS Configuration for all your hosts in minutes!"</i></p>

  <p>
    <a href="https://github.com/Zenko64/NixQuick/wiki"><img src="https://img.shields.io/badge/docs-wiki-blue" alt="Wiki"></a>
    <img src="https://img.shields.io/badge/NixOS-unstable-5277C3?logo=nixos&logoColor=white" alt="NixOS Unstable">
    <img src="https://img.shields.io/badge/flake-parts-green" alt="Flake Parts">
  </p>
</div>
<div align="center">
  <video width="640" height="360" controls>
    <source src="https://user-cdn.hackclub-assets.com/019f2296-0e4c-70b6-a3ef-6a8952e9c541/demo.mp4" type="video/mp4">
  </video>
</div>
<hr>


https://github.com/user-attachments/assets/62ffb655-a05e-4175-a3fa-40c00403a144


## Introduction

NixQuick is a Nix configuration framework built with ease-of-use in mind.
It abstracts away the tedious parts - a working Hyprland setup, desktop
shells and their components, theming, boot, and deployment - so you can go
from fork to a fully configured system in minutes.

## Features

- **Auto-discovered hosts** - drop a folder in `hosts/`, get a system. Grouped by architecture and class (desktop, server, installer).
- **Fast Desktops** - Obtain a fully configured Hyprland desktop in just minutes.
- **Themes** - Stylix-powered, switchable per host and overridable per user.
- **Dendritic modules** - NixOS and Home-Manager configurations live no the same file. Easy to maintain.
- **Deployment ready** - ISO, PXE netboot, RPI Images, remote installs via nixos-anywhere and Disko.
- **Secure by default** - Secure Boot via Lanzaboote, SOPS secrets, pre-hardened server class.

## Quick Start

```sh
git clone https://github.com/Zenko64/NixQuick.git
cd NixQuick
nix develop # or "direnv allow"

cp -r _templates/hosts/x86_64-desktops/desktop hosts/x86_64-desktops/myhost

# Edit your configuration, then
sudo nixos-rebuild switch --flake .#myhost
```

Full walkthrough in the [wiki](https://github.com/Zenko64/NixQuick/wiki/Get-Started).

## Modules

NixQuick was designed around easily creating and updating your system's
modules, and deploying a functional system in as little time as possible. Home-Manager and NixOS modules are tightly integrated in the same
Nix file, using the Dendritic pattern provided by Flake-Parts and
Import-Tree for automatically importing them.

Fork this project, edit any module you want, add your own hosts, and flip
the modules you want applied to each host ON through the NixQuick options
namespace. Per-user differences are handled on the Homes side, and defaults
for all users can be set with Home-Manager sharedModules. Adding new
features as modules is just adding a file.

```nix
local = {
  desktop = {
    theme = "catppuccin-mocha";
    compositors.hyprland.enable = true;
    greeters.tuigreet.enable = true;
  };
  boot.loader.systemd-boot.enable = true;
};
```

All options are documented in the [wiki](https://github.com/Zenko64/NixQuick/wiki/Modules).

## Available Themes

| Catppuccin | TokyoNight | Gruvbox |
|---|---|---|
| `catppuccin-mocha` | `tokyoNight-dark` | `gruvbox-dark` |
| `catppuccin-macchiato` | `tokyoNight-light` | |
| `catppuccin-latte` | `tokyoNight-moon` | |
| `catppuccin-frappe` | `tokyoNight-storm` | |

Adding your own theme is a single file, see the
[Themes wiki page](https://github.com/Zenko64/NixQuick/wiki/Themes).

## Documentation

- [Get Started](https://github.com/Zenko64/NixQuick/wiki/Get-Started)
- [Hosts](https://github.com/Zenko64/NixQuick/wiki/Hosts)
- [Modules](https://github.com/Zenko64/NixQuick/wiki/Modules)
- [Themes](https://github.com/Zenko64/NixQuick/wiki/Themes)
- [DevShells](https://github.com/Zenko64/NixQuick/wiki/DevShells)
- [Deployment](https://github.com/Zenko64/NixQuick/wiki/Deployment)
