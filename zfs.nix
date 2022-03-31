{ config, pkgs, ... }:

{ boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "c8c46876";
  boot.zfs.devNodes = "/dev/disk/by-id";
