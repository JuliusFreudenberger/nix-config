{
  disko.devices = {
    disk = {
      disk1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-Samsung_SSD_850_PRO_256GB_S251NX0H423575T";
        content = {
          type = "gpt";
          partitions = {
            MBR = {
              type = "EF02"; # for grub MBR
              size = "1M";
              priority = 1; # Needs to be first partition
            };
            ESP = {
              priority = 1;
              name = "ESP";
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            crypt_p1 = {
              size = "100%";
              content = {
                type = "luks";
                name = "p1";
                settings = {
                  allowDiscards = true;
                };
              };
            };
          };
        };
      };
      disk2 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-Samsung_SSD_850_PRO_256GB_S251NXAG833792N";
        content = {
          type = "gpt";
          partitions = {
            MBR = {
              type = "EF02"; # for grub MBR
              size = "1M";
              priority = 1; # Needs to be first partition
            };
            ESP = {
              priority = 1;
              name = "ESP";
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot-fallback";
                mountOptions = [ "umask=0077" ];
              };
            };
            crypt_p2 = {
              size = "100%";
              content = {
                type = "luks";
                name = "p2";
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-d raid1"
                    "-m raid1"
                    "/dev/mapper/p1"
                  ];
                  subvolumes = {
                    "/rootfs" = {
                      mountpoint = "/";
                    };
                    "/home" = {
                      mountOptions = [ "compress=zstd" ];
                      mountpoint = "/home";
                    };
                    "/nix" = {
                      mountOptions = [ "compress=zstd" "noatime" ];
                      mountpoint = "/nix";
                    };
                    "/pve-cluster" = {
                      mountOptions = [ "compress=zstd" ];
                      mountpoint = "/var/lib/pve-cluster";
                    };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "32G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
