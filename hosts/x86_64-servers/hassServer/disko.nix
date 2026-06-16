# Automatic Disk Partitioning Configuration
{ ... }:
{
  disko.devices.disk.osDisk = {
    type = "disk";
    device = "/dev/disk/by-path/platform-80860F14:00"; # HWPath is preferred on these kinds of devices.
    content = {
      type = "gpt";
      partitions = {
        NixBoot = {
          name = "NixBoot";
          size = "128M"; # Limit to 2 Generations (Boot with 1generation wheighs 40MB)
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        NixRoot = {
          name = "NixRoot";
          size = "100%";
          content = {
            extraArgs = [ "-L" "NixRoot" ]; # Mkfs.ext4 doesn't strip space from arg like btrfs does oddly.
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
            mountOptions = [ "noatime" "discard" "commit=15" ]; # Drive optimizations
          };
        };
      };
    };
  };
}
