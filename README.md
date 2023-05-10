# Packer Apline 3.17 cloud-init 
=================

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
root password is set randomly you could change if needed.

Once image is build you could use it with cloud-init file.

In build file you could find an example tu create an http server and use it with script.

Origin & References
-------------------
https://github.com/troglobit/alpine-qemu-image <== big thanks for your work
