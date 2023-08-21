# Packer Alpine 3.17/18.2 cloud-init 
=================

Just some pocs/study in order to deploy some vm on Nutanix Clusters

1 - Alpine 3.17 QEMU image
=================
How to setup a fonctional Alpine Linux (3.17) qcow2 image with a working cloud-init for Nutanix Cluster (6.5)

** install packer (ubuntu 23.04) **
```bash
sudo apt install packer qemu-system-x86
```

Launch building.
```bash
bash build
```
root password is set randomly you could change it if needed.

Once image is build you could use it with cloud-init file.

In build file you could find an example tu create an http server and use it with script.

2 - Alpine 3.18.2 QEMU image
=================
same process

3- Windows 11 QEMU image
=================

Download regular image from microsoft or uupdump https://uupdump.net/ (download and build your iso).
Calculate sha256.
Change parameters in json file.
Download virtio-win-0.1.229.iso wich provide drivers for VM https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.229-1/ 


if you want to change password or user change in both files : 

answer_files/11-uefi-fr/Autounattend.xml
windows11EFI-fr.json


Origin & References
-------------------

BIG Thanks to thoses guys for helping me to upgrade my skills.

https://github.com/troglobit/alpine-qemu-image 
https://github.com/StefanScherer/packer-windows 
