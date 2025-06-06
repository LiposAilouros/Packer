#!/bin/bash
#
set -euo pipefail
#
export DEBIAN_FRONTEND=noninteractive
#
## This forces GRUB to use PARTUUID instead of UUID for root=, which does not
## work for us, see PUBM-37334 and
## https://salsa.debian.org/cloud-team/debian-cloud-images/-/merge_requests/388
#rm /etc/default/grub.d/10_cloud.cfg
#
## grub-cloud can cause problems after the server is installed - PUBM-22667
echo "begin"
sleep 300
apt-get -y purge grub-cloud-amd64
## Restore a default grub config as the old file belonged to grub-cloud-amd64 and got removed
## by the purge.
## Copying /usr/share/grub/default/grub to /etc/default/grub is otherwise done by
## grub-pc or grub-efi-amd64's postinst.
cp /usr/share/grub/default/grub /etc/default/grub
#
## Add contrib to allow ZFS installation
## Add non-free-firmware for AMD and Intel microcodes + Firmwares - PUBM-31999 / PUBM-38502
#sed -i "s/\bmain\b/& contrib non-free-firmware/" /etc/apt/sources.list.d/debian.sources
#
apt-get update
apt-get -y install --no-install-recommends mdadm lvm2 patch btrfs-progs amd64-microcode intel-microcode firmware-linux
apt-get -y install cloud-init cloud-guest-utils 
## We will install these in make_image_bootable.sh and only when ZFS is used
## linux-headers-amd64 needs to be manually specified because dkms only recommends it
#apt-get -y install --no-install-recommends --download-only linux-headers-amd64 zfs-dkms zfs-initramfs zfs-zed
apt-get -y dist-upgrade
#
## Download GRUB for legagy and UEFI servers, both can't be installed simultaneously - PUBM-22671.
apt-get -y install --no-install-recommends --download-only grub-efi-amd64
apt-get -y install --no-install-recommends --download-only grub-pc
## Make sure grub-efi-amd64 won't change the boot order.
echo "grub-efi-amd64 grub2/update_nvram boolean false" | debconf-set-selections
#
## Disable some cloud-init options:
## grub-dpkg sets an incorrect value to "grub-pc/install_devices" - PUBM-22667.
## growpart and resizefs are not needed and can cause problems with ZFS partitions.
#sed -Ei '/^ - (grub-dpkg|growpart|resizefs)/d' /etc/cloud/cloud.cfg
#
## Make ifupdown more verbose to help detect bugs/misconfigurations - PUBM-17724
##sed -i 's/^#VERBOSE=.*/VERBOSE=yes/' /etc/default/networking
#
#
#
#patch /etc/default/grub << 'EOF'
#@@ -1,3 +1,6 @@
#+# This file is based on /usr/share/grub/default/grub, some settings
#+# have been changed by OVHcloud.
#+
## If you change this file, run 'update-grub' afterwards to update
## /boot/grub/grub.cfg.
## For full documentation of the options in this file, see:
#@@ -6,8 +9,9 @@
#GRUB_DEFAULT=0
#GRUB_TIMEOUT=5
#GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
#-GRUB_CMDLINE_LINUX_DEFAULT="quiet"
#-GRUB_CMDLINE_LINUX=""
#+GRUB_CMDLINE_LINUX_DEFAULT=""
#+GRUB_CMDLINE_LINUX="nomodeset iommu=pt"
#+GRUB_GFXPAYLOAD_LINUX="text"
#       
##        # Uncomment to enable BadRAM filtering, modify to suit your needs
##         # This works with Linux (no patch required) and with any kernel that obtains
#EOF
#
#         # Remove old machine-id
         rm -f /etc/machine-id

