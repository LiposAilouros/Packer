#!/bin/sh
sed -i s/'PermitRootLogin yes'/'PermitRootLogin no'/g /etc/ssh/sshd_config
echo "https://mirrors.ircam.fr/pub/alpine/v3.18/main/" >> /etc/apk/repositories
echo "https://mirrors.ircam.fr/pub/alpine/v3.18/community/" >> /etc/apk/repositories
apk update
apk add e2fsprogs
apk add util-linux
apk add e2fsprogs-extra
apk add python3 py3-pip py3-netifaces py3-pyserial
apk add iptables
apk add cloud-init
setup-cloud-init
apk upgrade 
