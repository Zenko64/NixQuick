<div align="center">
<p align="center">
  <img src="https://raw.githubusercontent.com/Zenko64/NixQuick/refs/heads/main/assets/logo.svg" width="128" alt="NixQuickBanner">
</p>
  <h1>NixQuick</h1>

  <p><i>"Achieve a beautiful NixOS Configuration for all your hosts in minutes!"</i></p>
</div>
<hr>

### Introduction
NixQuick is a Nix Configuration Framework, with ease-of-use in mind. It abstracts away the more tedious parts, such as, manually writing a working Hyprland config, setting up desktop shells and their components, among others.

## Modules
NixQuick was designed around easily creating and updating your system's modules.

Home-Manager and NixOS modules are tightly integrated in the same Nix file, using the Dendritic pattern, provided by Flake-Parts and Import-Tree for automatically importing the modules.

You can just fork this project and edit any module you want (or not), add your own hosts, configure them with programs and users as regular, set your user's Home Configurations (Basic Manual Setup required), use the NixQuick Options Namespace and flip the modules you want applied to the host ON. And if each user has different requirements, you can override these on the Homes side for each user. You can set default behaviors using HomeManager sharedModules.
It is also fairly easy to add new features as modules to NixQuick.

### Available Themes
#### Catppuccin
- catppuccin-mocha
- catppuccin-macchiato
- catppuccin-latte
- catppuccin-frappe
#### TokyoNight
- tokyoNight-dark
- tokyoNight-light
- tokyoNight-moon
- tokyoNight-storm
