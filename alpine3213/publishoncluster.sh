#/bin/bash

set -eux
# Set log file
DIR="/home/debian/alpine318"
LOG="${DIR}/publishonclusterlog_$(date +%Y-%m-%d_%Hh%M).log"
touch "${LOG}"
exec 1>"${LOG}"
exec 2>&1

SERVICENAME=cluster-1449.nutanix.ovh.net
ENS4=172.16.3.254/22
GWNETMASK=255.255.252.0
VMPRIVATEIP=51.210.201.21
CLOUDIMGURL=$3
CLOUDIMGNAME=$(echo $CLOUDIMGURL | cut -f 4 -d "/")
SUBNETPUBLIC=base
SUBNETPRIVATE=infra
SUBNETPROD=production
DOMAIN=ovh.local
PASSWORD=$1
PCPUBLIC=$2
VMNAME=$2
DNS=213.186.33.99
NTP=ntp0.ovh.net

RED='\033[0;31m'
NC='\033[0m' # No Color
BLACK='\033[0;30m'        # Black
GREEN='\033[0;32m'        # Green
BLUE='\033[0;34m'         # Blue
#echo -e "I ${RED}love${NC} OVHcloud"

#function declaration
SSH() {
    payload=(${@})
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $DIR/keytmp ${payload[@]:0}
}

uploadimg()
{
  #upload img from url / name set in vars file
  echo -e "${GREEN}creation du vm.json${NC}"
  echo -e "${GREEN}create json file with commum parameters${NC}"
  echo '{"spec": {"name": "IMGNAME","resources": {"image_type": "DISK_IMAGE","source_uri": "URL","architecture": "X86_64"}},"metadata": {"kind": "image","owner_reference": {"kind": "user","uuid": "00000000-0000-0000-0000-000000000000","
name": "admin"}}}'>img.json
  sed -i'.original' "s^URL^$CLOUDIMGURL^g" "img.json"
  sed -i'.original' "s^IMGNAME^$CLOUDIMGNAME^g" "img.json"
  curl -k -H Accept:application/json -H Content-Type:application/json -u "admin:$PASSWORD" -X POST https://$PCPUBLIC:9440/api/nutanix/v3/images -d @img.json | jq . || exit 1
  img_uuid=$(curl -s -k -H Accept:application/json -H Content-Type:application/json -u "admin:$PASSWORD" -X POST https://$PCPUBLIC:9440/api/nutanix/v3/images/list '-d{"length": 100}' | jq -r "[.entities[] | select( .spec.name | contains(\"${CLOUDIMGNAME}\")) | .metadata.uuid][0]")
  SLEEP=0
  until [[ "${img_uuid}" =~ [0-9a-zA-Z]{8}-([0-9a-zA-Z]{4}-){3}[0-9a-zA-Z]{12} ]]
  do
      echo -e "${GREEN}Image downloading${NC}"
    sleep 2
    SLEEP=$(( SLEEP + 2))
    if [ $SLEEP -gt 300 ]
    then
        echo -e "${RED}Fail downloading img${NC}"
      exit 1
    fi
    img_uuid=$(curl -s -k -H Accept:application/json -H Content-Type:application/json -u "admin:$PASSWORD" -X POST https://$PCPUBLIC:9440/api/nutanix/v3/images/list -d{"length": 100} | jq -r "[.entities[] | select( .spec.name | contains(\"${CLOUDIMGNAME}\")) | .metadata.uuid][0]")
  done
}


#Begin
uploadimg
