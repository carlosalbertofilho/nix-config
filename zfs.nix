{ config, pkgs, ... }:

{ boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "975dce5e";
  boot.zfs.devNodes = "/dev/disk/by-id";
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  swapDevices = [
    { device = "/dev/disk/by-id/nvme-Force_MP510_21028236000128865E98-part4"; randomEncryption.enable = true; }
  ];
  systemd.services.zfs-mount.enable = false;
  environment.etc."machine-id".source = "/state/etc/machine-id";
  environment.etc."zfs/zpool.cache".source
    = "/state/etc/zfs/zpool.cache";
  boot.loader.efi.efiSysMountPoint = "/boot/efis/nvme-Force_MP510_21028236000128865E98-part1";
  ##if UEFI firmware can detect entries
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader = {
    generationsDir.copyKernels = true;
    ##for problematic UEFI firmware
    grub.efiInstallAsRemovable = false;
    grub.enable = true;
    grub.version = 2;
    grub.copyKernels = true;
    grub.efiSupport = true;
    grub.zfsSupport = true;
    # for systemd-autofs
    grub.extraPrepareConfig = ''
      mkdir -p /boot/efis /boot/efi
      for i in  /boot/efis/*; do mount $i ; done
      mount /boot/efi
    '';
    grub.extraInstallCommands = ''
       export ESP_MIRROR=$(mktemp -d -p /tmp)
       cp -r /boot/efis/nvme-Force_MP510_21028236000128865E98-part1/EFI $ESP_MIRROR
       for i in /boot/efis/*; do
        cp -r $ESP_MIRROR/EFI $i
       done
       rm -rf $ESP_MIRROR
    '';
    grub.devices = [
      "/dev/disk/by-id/nvme-Force_MP510_21028236000128865E98"
    ];
  };
  users.users.root.initialHashedPassword = "$6$4gHdAgY24SV9byBO$JSEik0y0PB6h5n2EGYVlp/SJEPnrzllShzvdsrVWaQX/l1nH4YLAXFkHFl2LLLPk2jFzjODsz9V55SFlH0OSS1";
}
