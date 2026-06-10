# Automatic Disk Partitioning Configuration
{ ... }:
{
  disko.devices.disk.osDisk = {
    type = "disk";
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        NixBoot = {
          name = "NixBoot";
          size = "1G";
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
            type = "btrfs";
            extraArgs = [ "-L NixRoot" ];
            subvolumes = {
              "@" = {
                mountpoint = "/";
                mountOptions = [ "compress=zstd" ];
              };
              "@home" = {
                mountpoint = "/home";
                mountOptions = [ "compress=zstd" ];
              };
              "@nix" = {
                mountpoint = "/nix";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
              };
            };
          };
        };
      };
    };
  };
}
