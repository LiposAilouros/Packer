# Packer 
=================

Just some pocs/study in order to deploy some vm on Nutanix Clusters

** install packer (ubuntu 23.04) and some stuffs to debug ** 
```bash
sudo apt install packer qemu-kvm virt-manager virtinst libvirt-clients bridge-utils libvirt-daemon-system remmina ovmf -y
```

Yes there is remina because I usually connect to the packer vm to follow (and debug) build throught VNC.


1 - Alpine QEMU image
=================
How to setup a fonctional Alpine Linux (3.18.2) qcow2 image with a working cloud-init for Nutanix Cluster (6.5)

root password is set randomly you could change it if needed.

Launch building.
```bash
build &
```
Once image is build you could use it with cloud-init file.

In build file you could find an example tu create an http server and use it with script.

2- Windows 11 QEMU image
=================

Download regular image from microsoft or uupdump https://uupdump.net/ (download and build your iso).
Calculate sha256.
Change parameters in json file.
Download virtio-win-0.1.229.iso wich provide drivers for VM https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.229-1/ 


if you want to change password or user change in both files : 

answer_files/11-uefi-fr/Autounattend.xml
windows11EFI-fr.json


3- Windows 2019 fr uefi QEMU image
=================

download virtio image in the base directory.
download windows 2019 french iso image in the OS_ISO directory.
launch 
```bash
bash build & 
```
The script will calculate sha256 from iso image and launch qcow2 build.

This will install os for the second entry of the ISO, you'll need to change in the answer file "INDEX" with the correct entry.

Image is "sysprep" ready. You'll need to setup a password at the fisrt boot.

4- Todo 
================
download virtio image directly from sources (fedora) 

Origin & References
-------------------

BIG Thanks to thoses guys for helping me to upgrade my skills.

https://github.com/troglobit/alpine-qemu-image 
https://github.com/StefanScherer/packer-windows 
