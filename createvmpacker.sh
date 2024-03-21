#!/bin/bash

# requirements :
# upload an ubuntu image on your PE cluster and update the name below
# this script work on alpine linux, sshpass and cloud-utils-localds package are needed
# it would also work on debian like system
# VM will be created in a container wich the name begining by "default".
 
# how it work ?
# create a VM with hardware virtualisation (for nested virtualisation) with a cloud-init file to setup needed dependancies.

# adjust variable below disk, mem, vcpu, network, password and cvm IP
# You also need to adjust user-data.yaml file to change ip, user, password or adding any other personal configuration.


nutanixcvmpassword='nutanix/4u'
CVM1='172.16.1.1'
VMNAME='packer'
IMGNAME='jammy-server-cloudimg-amd64.img'
networkname='infra'

createcloudVM()
{
    TYPEISO="kDiskImage"
    disk="300G"
    container=$(/usr/bin/sshpass -p "${nutanixcvmpassword}" ssh -o StrictHostKeyChecking=no nutanix@${CVM1} "/home/nutanix/prism/cli/ncli container list | grep 'VStore Name' | grep -oE 'default-[a-z]{1,}-[0-Z]{1,}'")
    mem="16G"
    num_cores_per_vcpu=2
    vcpu=4
    # checking if user-data exists
    if [ ! -f "user-data.yaml" ]; then
	    echo "No user-data.yaml file found exiting"
   	    exit 1
    fi
   # Create and power on VM
    /usr/bin/sshpass -p "${nutanixcvmpassword}" ssh -o StrictHostKeyChecking=no nutanix@${CVM1} "/usr/local/nutanix/bin/acli vm.create ${VMNAME} memory=$mem num_cores_per_vcpu=$num_cores_per_vcpu num_vcpus=$vcpu uefi_boot=true hardware_virtualization=true"
    /usr/bin/sshpass -p "${nutanixcvmpassword}" ssh -o StrictHostKeyChecking=no nutanix@${CVM1} "/usr/local/nutanix/bin/acli vm.disk_create ${VMNAME} clone_from_image="${IMGNAME}""
    /usr/bin/sshpass -p "${nutanixcvmpassword}" ssh -o StrictHostKeyChecking=no nutanix@${CVM1} "/usr/local/nutanix/bin/acli vm.disk_update ${VMNAME} disk_addr=scsi.0 new_size="${disk}"" 2>/dev/null
    /usr/bin/sshpass -p "${nutanixcvmpassword}" ssh -o StrictHostKeyChecking=no nutanix@${CVM1} "/usr/local/nutanix/bin/acli vm.nic_create ${VMNAME} connected=true network=${networkname}"
    # cloud-localds user-data.img user_data.yaml
    cloud-localds user-data.img user-data.yaml
    # create temporary webserver on port 9234, change port if needed 
    python3 -m http.server 9234 > /dev/null 2>&1 &
    mypid=$!
    # getting local ip adress
    myip=$(ip route get 8.8.8.8 | awk -F ' ' '{ for (i=1;i<=NF;i++) if ($i == "src") print $(i+1) }')
    #myip=if previous command does not work set myip panually
    /usr/bin/sshpass -p "${nutanixcvmpassword}" ssh -o StrictHostKeyChecking=no nutanix@${CVM1} "/usr/local/nutanix/bin/acli image.create "init-${VMNAME}" source_url=http://${myip}:9234/user-data.img image_type=kDiskImage container=SelfServiceContainer"
    /usr/bin/sshpass -p "${nutanixcvmpassword}" ssh -o StrictHostKeyChecking=no nutanix@${CVM1} "/usr/local/nutanix/bin/acli vm.disk_create ${VMNAME} clone_from_image="init-${VMNAME}""
    /usr/bin/sshpass -p "${nutanixcvmpassword}" ssh -o StrictHostKeyChecking=no nutanix@${CVM1} "/usr/local/nutanix/bin/acli vm.on ${VMNAME}"
    /usr/bin/sshpass -p "${nutanixcvmpassword}" ssh -o StrictHostKeyChecking=no nutanix@${CVM1} "echo yes | /usr/local/nutanix/bin/acli image.delete "init-${VMNAME}""
    rm -f user-data.img
    kill ${mypid}

}

# 1- installing dependancies
SSHPASS="$(command -v sshpass)"
CLOUDLOCALDS="$(command -v cloud-localds)"

if [ "${SSHPASS}" = "" ] || [ "${CLOUDLOCALDS}" = "" ]; then
    echo "Missing dependancies, try to install sshpass cloud-utils-localds packages"
fi

createcloudVM
