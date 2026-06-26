# Automatic Disk Partitioning Configuration
# Read Disko Documentation for more information.
{ ... }:
{
  disko.devices.disk.osDisk = {
    type = "disk";
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {

        # EFI Boot Partition Configuration
        NixBoot = {
          name = "NixBoot";
          size = "1G"; # 1GiB Size
          type = "EF00"; # EFI System Partition Type
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        # ROOT Partition Configuration
        NixRoot = {
          name = "NixRoot";
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-L" "NixRoot" ]; # Extra Args Can Be Encoded Differently Depending On The Disk Type. This Sets The Label.
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
