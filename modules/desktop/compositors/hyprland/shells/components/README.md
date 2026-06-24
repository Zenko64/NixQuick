# Shell Components

These are Shell Components.
You should make a shell component if your program requires manual configuration and other shells might use it, as to avoid code duplication.
These can make up a shell, and contain different components such as:

- Lockscreen Programs
- Idle Management Daemons
- Independent Widgets

Each component is a flake-parts module that contributes to `flake.modules.homeManager.desktop`, so `import-tree` picks it up automatically — shells do **not** import components directly. Every component declares an internal `enable` option (default `false`) and wraps its `config` in `lib.mkIf cfg.enable {}`. A shell turns on the components it wants by setting their `enable` inside its own shell-gated `config` block (ex: Caelestia provides its own notifications, so it leaves `mako.enable` off).

> Note: files/directories prefixed with `_` are skipped by `import-tree`. This directory must therefore stay unprefixed for components to be auto-loaded.

### Custom Component Attributes
> To pass a custom module attribute to a component, define the option on the component, under the namespace dynamically, and mark it internal, as normally users shouldn't directly interact with it. ```${namespace}.desktop.compositors.hyprland._components.yourOption = lib.mkOption {internal = true; ...};```