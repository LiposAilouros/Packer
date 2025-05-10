#!/bin/sh
sed -i s/'PermitRootLogin yes'/'PermitRootLogin no'/g /etc/ssh/sshd_config
echo "https://alpinelinux.mirrors.ovh.net/v3.21/main" > /etc/apk/repositories
echo "https://alpinelinux.mirrors.ovh.net/v3.21/community" >> /etc/apk/repositories
#setup-apkrepos -cf
apk update
apk add e2fsprogs
apk add util-linux
apk add e2fsprogs-extra
apk add python3 py3-pip py3-netifaces py3-pyserial
apk add iptables
apk add cloud-init
setup-cloud-init
#apk list -vv
apk upgrade 
echo "#!/bin/sh
apk upgrade -U -q --no-interactive" >/etc/periodic/daily/update.sh

