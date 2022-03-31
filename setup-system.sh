#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash parted cryptsetup zfsutil

# Unique pool suffix. ZFS expects pool names to be unique,
# therefore it’s recommended to create pools with a unique suffix
INST_UUID=$(dd if=/dev/urandom bs=1 count=100 2>/dev/null | tr -dc 'a-z0-9' | cut -c-6)

# Identify this installation in ZFS filesystem path
INST_ID=nixos

# Root on ZFS configuration file name
INST_CONFIG_FILE='zfs.nix'

# Declare disk array
DISK='/dev/disk/by-id/ata-FOO /dev/disk/by-id/nvme-BAR'

# Choose a primary disk
INST_PRIMARY_DISK=$(echo $DISK | cut -f1 -d\ )

# Set vdev topology, possible values are:
# - (not set, single disk or striped; no redundancy)
# - mirror
# - raidz1
# - raidz2
# - raidz3
INST_VDEV=

### Set partition size
# Set ESP size
INST_PARTSIZE_ESP=2 # in GB
# Set boot pool size.
INST_PARTSIZE_BPOOL=4 # in GB
# Set swap size
INST_PARTSIZE_SWAP=8 # in GB
# Root pool size, use all remaining disk space if not set:
INST_PARTSIZE_RPOOL=


##########################################################
############    Partition Configuration    ###############
##########################################################

# 1. All content will be irrevocably destroyed
for i in ${DISK}; do
    blkdiscard -f $i &
done
wait

# 2. Partition the disks
for i in ${DISK}; do
    sgdisk --zap-all $i
    sgdisk -n1:1M:+${INST_PARTSIZE_ESP}G -t1:EF00 $i
    sgdisk -n2:0:+${INST_PARTSIZE_BPOOL}G -t2:BE00 $i
if [ "${INST_PARTSIZE_SWAP}" != "" ]; then
    sgdisk -n4:0:+${INST_PARTSIZE_SWAP}G -t4:8200 $i
fi
if [ "${INST_PARTSIZE_RPOOL}" = "" ]; then
    sgdisk -n3:0:0   -t3:BF00 $i
else
    sgdisk -n3:0:+${INST_PARTSIZE_RPOOL}G -t3:BF00 $i
fi
    sgdisk -a1 -n5:24K:+1000K -t5:EF02 $i
done

# list paths
ls /dev/disk/by-id/
wait

# 3. Create boot pool
disk_num=0; for i in $DISK; do disk_num=$(( $disk_num + 1 )); done
if [ $disk_num -gt 1 ]; then INST_VDEV_BPOOL=mirror; fi

zpool create \
    -o compatibility=grub2 \
    -o ashift=12 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O canmount=off \
    -O compression=lz4 \
    -O devices=off \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O mountpoint=/boot \
    -R /mnt \
    bpool_$INST_UUID \
    $INST_VDEV_BPOOL \
    $(for i in ${DISK}; do
       printf "$i-part2 ";
    done)

# 4. Create root pool
zpool create \
    -o ashift=12 \
    -o autotrim=on \
    -R /mnt \
    -O acltype=posixacl \
    -O canmount=off \
    -O compression=zstd \
    -O dnodesize=auto \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O mountpoint=/ \
    rpool_$INST_UUID \
    $INST_VDEV \
   $(for i in ${DISK}; do
      printf "$i-part3 ";
     done)

# 5. Create root system encrypted container
zfs create \
 -o canmount=off \
 -o mountpoint=none \
 -o encryption=aes-256-gcm \
 -o keylocation=prompt \
 -o keyformat=passphrase \
 rpool_$INST_UUID/$INST_ID

# 6. Format and mount ESP
for i in ${DISK}; do
    mkfs.vfat -n EFI ${i}-part1
    mkdir -p /mnt/boot/efis/${i##*/}-part1
    mount -t vfat ${i}-part1 /mnt/boot/efis/${i##*/}-part1
done

# 7. Create optional user data datasets to omit data from rollback
zfs create -o canmount=on rpool_$INST_UUID/$INST_ID/DATA/default/var/games
zfs create -o canmount=on rpool_$INST_UUID/$INST_ID/DATA/default/var/www
# for GNOME
zfs create -o canmount=on rpool_$INST_UUID/$INST_ID/DATA/default/var/lib/AccountsService
# for Docker
zfs create -o canmount=on rpool_$INST_UUID/$INST_ID/DATA/default/var/lib/docker
# for NFS
zfs create -o canmount=on rpool_$INST_UUID/$INST_ID/DATA/default/var/lib/nfs
# for LXC
zfs create -o canmount=on rpool_$INST_UUID/$INST_ID/DATA/default/var/lib/lxc
# for LibVirt
zfs create -o canmount=on rpool_$INST_UUID/$INST_ID/DATA/default/var/lib/libvirt
##other application
# zfs create -o canmount=on rpool_$INST_UUID/$INST_ID/DATA/default/var/lib/$name


##########################################################
############    System Configuration    ##################
##########################################################


# 8. Generate initial NixOS system configuration
nixos-generate-config --root /mnt

# 9. Edit config file to import ZFS options
sed -i "s|./hardware-configuration.nix|./hardware-configuration-zfs.nix ./${INST_CONFIG_FILE}|g" /mnt/etc/nixos/configuration.nix
# backup, prevent being overwritten by nixos-generate-config
mv /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/hardware-configuration-zfs.nix

# 10. ZFS options
tee -a /mnt/etc/nixos/${INST_CONFIG_FILE} <<EOF
{ config, pkgs, ... }:

{ boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "$(head -c 8 /etc/machine-id)";
  boot.zfs.devNodes = "${INST_PRIMARY_DISK%/*}";
EOF

# ZFS datasets should be mounted with -o zfsutil option:
sed -i 's|fsType = "zfs";|fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];|g' \
/mnt/etc/nixos/hardware-configuration-zfs.nix

# Allow EFI system partition mounting to fail at boot
sed -i 's|fsType = "vfat";|fsType = "vfat"; options = [ "x-systemd.idle-timeout=1min" "x-systemd.automount" "noauto" ];|g' \
/mnt/etc/nixos/hardware-configuration-zfs.nix

# Restrict kernel to versions supported by ZFS
tee -a /mnt/etc/nixos/${INST_CONFIG_FILE} <<EOF
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
EOF

##########################################################
############      Encrypt boot pool       ################
##########################################################

# 1. Add package:
tee -a /mnt/etc/nixos/${INST_CONFIG_FILE} <<EOF
  environment.systemPackages = [ pkgs.cryptsetup ];
EOF

# 2. LUKS password:
echo
echo Encrypt boot pool  
echo
echo "Enter you LUKS password: "
read -r answer 
echo Password is $answer
wait
LUKS_PWD=$answer

# 3. Create encryption keys:
mkdir -p /mnt/etc/cryptkey.d/
chmod 700 /mnt/etc/cryptkey.d/
dd bs=32 count=1 if=/dev/urandom of=/mnt/etc/cryptkey.d/rpool_$INST_UUID-${INST_ID}-key-zfs
dd bs=32 count=1 if=/dev/urandom of=/mnt/etc/cryptkey.d/bpool_$INST_UUID-key-luks
chmod u=r,go= /mnt/etc/cryptkey.d/*

# 4. Backup boot pool:
zfs snapshot -r bpool_$INST_UUID/$INST_ID@pre-luks
zfs send -Rv bpool_$INST_UUID/$INST_ID@pre-luks > /mnt/root/bpool_$INST_UUID-${INST_ID}-pre-luks

# 5. Unmount EFI partition:
for i in ${DISK}; do
 umount /mnt/boot/efis/${i##*/}-part1
done
umount /mnt/boot/efi

# 6. Destroy boot pool:
zpool destroy bpool_$INST_UUID

# 7. Create LUKS containers:
for i in ${DISK}; do
    cryptsetup luksFormat -q --type luks1 --key-file /mnt/etc/cryptkey.d/bpool_$INST_UUID-key-luks $i-part2
    echo $LUKS_PWD | cryptsetup luksAddKey --key-file /mnt/etc/cryptkey.d/bpool_$INST_UUID-key-luks $i-part2
    cryptsetup open ${i}-part2 ${i##*/}-part2-luks-bpool_$INST_UUID --key-file /mnt/etc/cryptkey.d/bpool_$INST_UUID-key-luks
    tee -a /mnt/etc/nixos/${INST_CONFIG_FILE} <<EOF
    boot.initrd.luks.devices = {
        "${i##*/}-part2-luks-bpool_$INST_UUID" = {
        device = "${i}-part2";
        allowDiscards = true;
        keyFile = "/etc/cryptkey.d/bpool_$INST_UUID-key-luks";
        };
    };
    EOF
done

# 8. Embed key file in initrd:
tee -a /mnt/etc/nixos/${INST_CONFIG_FILE} <<EOF
  boot.initrd.secrets = {
    "/etc/cryptkey.d/rpool_$INST_UUID-${INST_ID}-key-zfs" = "/etc/cryptkey.d/rpool_$INST_UUID-${INST_ID}-key-zfs";
    "/etc/cryptkey.d/bpool_$INST_UUID-key-luks" = "/etc/cryptkey.d/bpool_$INST_UUID-key-luks";
  };
EOF

# 9. Recreate boot pool with mappers as vdev:
disk_num=0; for i in $DISK; do disk_num=$(( $disk_num + 1 )); done
if [ $disk_num -gt 1 ]; then INST_VDEV_BPOOL=mirror; fi


zpool create \
    -d -o feature@async_destroy=enabled \
    -o feature@bookmarks=enabled \
    -o feature@embedded_data=enabled \
    -o feature@empty_bpobj=enabled \
    -o feature@enabled_txg=enabled \
    -o feature@extensible_dataset=enabled \
    -o feature@filesystem_limits=enabled \
    -o feature@hole_birth=enabled \
    -o feature@large_blocks=enabled \
    -o feature@lz4_compress=enabled \
    -o feature@spacemap_histogram=enabled \
    -o ashift=12 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O canmount=off \
    -O compression=lz4 \
    -O devices=off \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O mountpoint=/boot \
    -R /mnt \
    bpool_$INST_UUID \
     $INST_VDEV_BPOOL \
    $(for i in ${DISK}; do
       printf "/dev/mapper/${i##*/}-part2-luks-bpool_$INST_UUID ";
    done)

# 10. Restore boot pool backup:
zfs recv bpool_${INST_UUID}/${INST_ID} < /mnt/root/bpool_$INST_UUID-${INST_ID}-pre-luks
rm /mnt/root/bpool_$INST_UUID-${INST_ID}-pre-luks

# 11. Mount boot dataset and EFI partitions:
zfs mount bpool_$INST_UUID/$INST_ID/BOOT/default

for i in ${DISK}; do
 mount ${i}-part1 /mnt/boot/efis/${i##*/}-part1
done

mount -t vfat ${INST_PRIMARY_DISK}-part1 /mnt/boot/efi

# 12.As keys are stored in initrd, set secure permissions for /boot:
chmod 700 /mnt/boot

# 13. Change root pool password to key file:
mkdir -p /etc/cryptkey.d/
cp /mnt/etc/cryptkey.d/rpool_$INST_UUID-${INST_ID}-key-zfs /etc/cryptkey.d/rpool_$INST_UUID-${INST_ID}-key-zfs
zfs change-key -l \
-o keylocation=file:///etc/cryptkey.d/rpool_$INST_UUID-${INST_ID}-key-zfs \
-o keyformat=raw \
rpool_$INST_UUID/$INST_ID

# 14. Enable GRUB cryptodisk:

tee -a /mnt/etc/nixos/${INST_CONFIG_FILE} <<EOF
  boot.loader.grub.enableCryptodisk = true;
EOF

echo
echo Important: Back up root dataset key
echo /etc/cryptkey.d/rpool_$INST_UUID-${INST_ID}-key-zfs
echo to a secure location.
echo

# 15. Generate password hash for hoot
INST_ROOT_PASSWD=$(mkpasswd -m SHA-512 -s)

# 16. Declare initialHashedPassword for root user:
tee -a /mnt/etc/nixos/${INST_CONFIG_FILE} <<EOF
  users.users.root.initialHashedPassword = "${INST_ROOT_PASSWD}";
EOF

# 17. Finalize the config file:
tee -a /mnt/etc/nixos/${INST_CONFIG_FILE} <<EOF
}
EOF

# 18. Take a snapshot of the clean installation, without state for future use:

zfs snapshot -r rpool_$INST_UUID/$INST_ID@install_start
zfs snapshot -r bpool_$INST_UUID/$INST_ID@install_start
