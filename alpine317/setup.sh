#!/bin/sh
echo "PasswordAuthentication yes" >>/etc/ssh/sshd_config
echo "KbdInteractiveAuthentication yes" >>/etc/ssh/sshd_config
mkdir /root/.ssh
echo "https://mirrors.ircam.fr/pub/alpine/v3.17/main/" >> /etc/apk/repositories
echo "https://mirrors.ircam.fr/pub/alpine/v3.17/community/" >> /etc/apk/repositories
apk update
apk add e2fsprogs
apk add util-linux
apk add e2fsprogs-extra
apk add python3 py3-pip py3-netifaces py3-pyserial
apk add cloud-init
setup-cloud-init
apk upgrade 
