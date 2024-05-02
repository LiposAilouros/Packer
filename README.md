# Packer 
=================

Just some pocs/study in order to deploy some vm on Nutanix Clusters, Windows image are also usable with some OVHcloud baremetal server (Bring Your Own Image feature).

1- Clone repo
2- Create vm packer on Nutanixcluster (with script included) or use a personnal computer with packer
3- For windows, upload ISO image in windowsxxxx/OS_ISO
4- Launch build script (./build &)
5- Get vnc address in logs if you want to follow/debug process
6- Use qcow2 file in images directory

Install Packer : https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli


Alpine image
=================
this will setup a fonctional Alpine Linux (3.18.2) qcow2 image with a working cloud-init for Nutanix Cluster (6.5)

root password is set randomly you could change it if needed.

Launch building.
```bash
build &
```
Once image is build you could use it with cloud-init file.


Windows 11 fr uefi image
=================
Installation is based on os name : 
<MetaData wcm:action="add">
<Key>/IMAGE/NAME</Key>
<Value>Windows 11 Professionnel</Value>

You can adapt to your iso in windows11-fr-uefi/answer_files/11-uefi-fr/Autounattend.xml.
Also be careful to the licence key file in the same file.

if you want to change password or user change in both files : 

windows11-fr-uefi/answer_files/11-uefi-fr/Autounattend.xml
packer.json
default account : Administrateur password : MySecurePassword


Windows 2019 fr uefi image
=================
Installation is based on os index (entry of os in the image) :
https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-setup-imageinstall-osimage-installfrom-metadata-key#values
You can adapt in Autounattend.xml

Image is "sysprep" ready. You'll need to setup a password at the fisrt boot.


Windows 2019 Essential us uefi image
=================
Installation is based on os index (entry of os in the image) :
https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-setup-imageinstall-osimage-installfrom-metadata-key#values
You can adapt in Autounattend.xml

Image is "sysprep" ready. You'll need to setup a password at the fisrt boot.


Windows 2019 Essential nosysprep us uefi image
=================
Installation is based on os index (entry of os in the image) :
https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-setup-imageinstall-osimage-installfrom-metadata-key#values
You can adapt in Autounattend.xml

No sysprep on this image, adapt password in both files : Autounattend.xml and packer.json.
Default credentials are Administrator / PasswOrd4g
Don't forget to disable autologon after install.


Windows 2022 us uefi image
=================
Installation is based on os index (entry of os in the image) :
https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-setup-imageinstall-osimage-installfrom-metadata-key#values
You can adapt in Autounattend.xml

Image is "sysprep" ready. You'll need to setup a password at the fisrt boot.


Todo 
================
Update this repos :-) 

Origin & References
-------------------

BIG Thanks to thoses guys for helping me to upgrade my skills. Also thanks to Jérémy, Louis, Sylvain, Gaetan, Ioannis, Jb, thanks guys, you rocks.

Inspired by :
https://github.com/troglobit/alpine-qemu-image 
https://github.com/StefanScherer/packer-windows 
