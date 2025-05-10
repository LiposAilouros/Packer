#!/bin/bash

set -eo pipefail

export DEBIAN_FRONTEND=noninteractive

# This script will run inside the newly installed system, no need to call chroot

configure_console() {
    echo "Getting console parameters from the cmdline"
    # Get the right console parameters (including SOL if available) from the
    # rescue's cmdline - PUBM-16534
    console_parameters="$(grep -Po '\bconsole=\S+' /proc/cmdline | paste -s -d" ")"
    if ! grep '^GRUB_CMDLINE_LINUX="' /etc/default/grub | grep -qF "$console_parameters"; then
        sed -Ei "s/(^GRUB_CMDLINE_LINUX=.*)\"\$/\1 $console_parameters\"/" /etc/default/grub
    fi

    # Also pass these parameters to GRUB
    parameters=$(sed -nE "s/.*\bconsole=ttyS([0-9]),([0-9]+)([noe])([0-9]+)\b.*/\1 \2 \3 \4/p" /proc/cmdline)
    if [[ ! "$parameters" ]]; then
        # No SOL, nothing to do
        return
    fi
    read -r unit speed parity bits <<< "$parameters"
    declare -A parities=([o]=odd [e]=even [n]=no)
    parity="${parities["$parity"]}"
    serial_command="serial --unit=$unit --speed=$speed --parity=$parity --word=$bits"

    if grep -qFx 'GRUB_TERMINAL="console serial"' /etc/default/grub; then
        # Configuration already applied
        return
    fi

    sed -i \
        -e "/^# Uncomment to disable graphical terminal/d" \
        -e "s/^#GRUB_TERMINAL=.*/GRUB_TERMINAL=\"console serial\"\nGRUB_SERIAL_COMMAND=\"$serial_command\"/" \
        /etc/default/grub
}

# The image contains /etc/mdadm/mdadm.conf which was created by mdadm's postinst script.
# It takes precedence over /etc/mdadm.conf which is generated during partitioning_apply.
# This means /etc/mdadm.conf will never be read so we can delete it.
rm -f /etc/mdadm.conf
# In order to create a prettier config file, we regenerate /etc/mdadm/mdadm.conf
# with a command similar to that of mdadm's postinst script.
/usr/share/mdadm/mkconf force-generate

configure_console

# Install ZFS packages if required
if lsblk -lno FSTYPE | grep -qxiF zfs_member; then
    apt-get -y install --no-install-recommends linux-headers-amd64 zfs-dkms zfs-initramfs zfs-zed
    # Make sure zpools are imported at boot, this is not required when / is ZFS because the initramfs
    # imports the pool. However, it is necessary if e.g. /home is ZFS and / is ext4.
    systemctl enable zfs-import-scan.service
fi

if [ -d /sys/firmware/efi ]; then
    echo "INFO - GRUB will be configured for UEFI boot"
    apt-get -y install --no-install-recommends grub-efi-amd64
    # grub-efi-amd64's postinst script does not install GRUB to the EFI partition,
    # it only updates it:
    # https://salsa.debian.org/grub-team/grub/-/commit/74eb20a6d7a3
    # https://salsa.debian.org/grub-team/grub/-/blob/debian/2.04-20/debian/postinst.in#L700
    # This means we need to install GRUB manually (and we do that after installing grub-efi-amd64
    # to prevent it from calling grub-install a second time).
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --no-nvram
    apt-get -y purge grub-pc-bin
else
    echo "INFO - GRUB will be configured for legacy boot"
    realBootDevicesById=()
    read -r bootDevice bootDeviceType < <(findmnt -A -c -e -l -n -T /boot/ -o SOURCE,FSTYPE)
    if [[ "$bootDeviceType" == "zfs" ]]; then
        bootDevices="$(zpool status -LP "${bootDevice%/*}" | grep -Po '/dev/\S+')"
    else
        bootDevices="$bootDevice"
    fi
    realBootDevices="$(lsblk -n -p -b -l -o TYPE,NAME $bootDevices -s | awk '$1 == "disk" && !seen[$2]++ {print $2}')"
    # realBootDevices are disks at this point
    for realBootDevice in $realBootDevices; do
        # When GRUB is manually installed, grub-pc/install_devices contains values from /dev/disk/by-id.
        # Each device has two links in that folder, e.g. ata-HGST_HUS726040ALA610_KXXXX and wwn-0x5000cca25defa844.
        # The postinst script for grub-pc keeps the first link after sorting them, see
        # https://salsa.debian.org/grub-team/grub/-/blob/debian/2.04-20/debian/postinst.in#L89
        # Using another link would cause it not to show up in the prompt to reconfigure the package.
        realBootDevicesById+=($(find -L /dev/disk/by-id/ -type b -samefile "$realBootDevice" | sort -us | head -n1))
    done
    echo "grub-pc grub-pc/install_devices multiselect $(sed 's/ /, /g' <<< "${realBootDevicesById[@]}")" | debconf-set-selections
    apt-get -y install --no-install-recommends grub-pc
    apt-get -y purge grub-efi-amd64-bin
fi
apt-get -y autoremove
apt-get -y clean

# Generate a new unique machine-id for this server
systemd-machine-id-setup
# To update mdadm.conf inside the initramfs (it will be the same as /etc/mdadm/mdadm.conf)
# Must run after ZFS installation for ZFS modules to be included if necessary
# and for the initramfs's host id to match that of the real root.
update-initramfs -u

# suicide cleanup
rm -fr /root/.ovh/
