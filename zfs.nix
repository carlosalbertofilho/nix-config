{ config, pkgs, ... }:

{ boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "ffc02d75";
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.generationsDir.copyKernels = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.copyKernels = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.zfsSupport = true;
  boot.loader.grub.extraPrepareConfig = ''
      mkdir -p /boot/efis
      for i in  /boot/efis/*; do mount $i ; done

      mkdir -p /boot/efi
      mount /boot/efi
    '';
  boot.loader.grub.extraInstallCommands = ''
    ESP_MIRROR=$(mktemp -d)
    cp -r /boot/efi/EFI $ESP_MIRROR
    for i in /boot/efis/*; do
    cp -r $ESP_MIRROR/EFI $i
    done
    rm -rf $ESP_MIRROR
    '';
boot.loader.grub.devices = [
      "/dev/disk/by-id/ata-KINGSTON_SA400S37240G_50026B7784007F5A"
    ];
users.users.root.initialHashedPassword =    "$6$p2Cl6ZQbB9sCBWKi$FbnPSUMzf8YRY5G2JJBvCjJvf0YWH8vs3lRxeQy2cw2d85Ur6tyqtwPEWxvgbBMEk8/gr75mNAFdTuTEfQUK4.";
}
