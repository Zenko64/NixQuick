{
  flake.modules.nixos.server =
    { config, lib, ... }:
    {
      services = {
        # System
        fwupd.enable = true;
        # Disks
        smartd.enable = true;
        fstrim.enable = true;

        # Time
        chrony.enable = true;
        timesyncd.enable = false; # Chrony is better for servers

        # Filesystems
        btrfs.autoScrub = lib.mkIf (config.fileSystems."/".fsType == "btrfs") {
          enable = true;
          interval = "monthly";
          fileSystems = [ "/" ];
        };
      };
    };
}
