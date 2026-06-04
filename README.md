# NixQuick
> Why pull your hair wiring everything from scratch when i can do it for you?
---
NixQuick is my personal semi-opinionated Nix Configuration, with ease-of-use in mind. It abstracts away the more annoying parts, for example, manually configuring and ricing every single aspect of Hyprland, and wiring desktop shells, and such.

It also supports servers! And every single option is overrideable by the native path to it, without custom escape-hatches or abstractions. It will just do it as you do and behaves as Nix.

## Modules
NixQuick was designed around easily creating and patching modules for your system.

Home-Manager and NixOS modules are tightly integrated in the same expresssion file, using the Dendritic pattern, provided by flake-parts and import-tree for automatically handling wiring the modules.

You can just fork this project, apply the changes you want to config, add your own hosts, configure them with programs and users as regular, configure your Home manager setups (Manual importing required), use the module options namespace and flip the modules you want applied to the host ON. And if each user has different requirements, you can override these on the Homes side for each user.

## Themes

### TokyoNight
- tokyoNight-dark
- tokyoNight-light
- tokyoNight-moon
- tokyoNight-storm
