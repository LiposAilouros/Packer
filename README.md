# Packer 
=================

Just some pocs/study in order to deploy some vm on Nutanix Clusters

Clone repo, create vm packer (with script included) or use a personnal computer, for windows, upload ISO image in windowsxxxx/OS_ISO, then launch build script.

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

BIG Thanks to thoses guys for helping me to upgrade my skills. Also thanks to Jérémy, Louis, Sylvain, thanks guys you rocks.

https://github.com/troglobit/alpine-qemu-image 
https://github.com/StefanScherer/packer-windows 
