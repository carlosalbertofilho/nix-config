{ config, pkgs, ... }:

{
 boot.loader = {
   efi = {
     canTouchEfiVariables = true;
     efiSysMountPoint = "/boot"; # ← use the same mount point here.
   };
   grub = {
      efiSupport = true;
      #efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
      device = "nodev";
   };
 };
}

