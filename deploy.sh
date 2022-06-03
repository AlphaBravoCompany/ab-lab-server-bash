#!/bin/bash

source vars.sh

set -e
G="\e[32m"
E="\e[0m"

if ! grep -q 'Ubuntu' /etc/issue
  then
    echo -----------------------------------------------
    echo "Not Ubuntu? Could not find Codename Ubuntu in lsb_release -a. Please switch to Ubuntu."
    echo -----------------------------------------------
    exit 1
fi

echo "Generating deployment files..."
## Update scripts with variables from vars
cp scripts/templates/lab-server.sh.tmpl scripts/deploy/lab-server.sh
while read line || [[ -n "$line" ]]
do
    key=$(awk -F= '{print $1}' <<< "$line")
    value=$(awk -F= '{print $2}' <<< "$line")
    sed -i 's|<'"$key"'>|'"$value"'|g' scripts/deploy/lab-server.sh
done < vars.sh

## Update Rancher Docker Compose file from vars
cp files/templates/rancher-docker-compose.yaml.tmpl files/deploy/rancher-docker-compose.yaml
while read line || [[ -n "$line" ]]
do
    key=$(awk -F= '{print $1}' <<< "$line")
    value=$(awk -F= '{print $2}' <<< "$line")
    sed -i 's|<'"$key"'>|'"$value"'|g' files/deploy/rancher-docker-compose.yaml
done < vars.sh

## Update proxy.sh file from vars
cp scripts/templates/proxy.sh.tmpl scripts/deploy/proxy.sh
while read line || [[ -n "$line" ]]
do
    key=$(awk -F= '{print $1}' <<< "$line")
    value=$(awk -F= '{print $2}' <<< "$line")
    sed -i 's|<'"$key"'>|'"$value"'|g' scripts/deploy/proxy.sh
done < vars.sh

## Update Portainer Docker Compose file from vars
cp files/templates/portainer-docker-compose.yaml.tmpl files/deploy/portainer-docker-compose.yaml
while read line || [[ -n "$line" ]]
do
    key=$(awk -F= '{print $1}' <<< "$line")
    value=$(awk -F= '{print $2}' <<< "$line")
    sed -i 's|<'"$key"'>|'"$value"'|g' files/deploy/portainer-docker-compose.yaml
done < vars.sh

## Update Portainer password file from vars
cp files/templates/portainer-password.txt.tmpl files/deploy/portainer-password.txt
while read line || [[ -n "$line" ]]
do
    key=$(awk -F= '{print $1}' <<< "$line")
    value=$(awk -F= '{print $2}' <<< "$line")
    sed -i 's|<'"$key"'>|'"$value"'|g' files/deploy/portainer-password.txt
done < vars.sh

## Update haproxy file from vars
cp files/templates/haproxy.cfg.tmpl files/deploy/haproxy.cfg
while read line || [[ -n "$line" ]]
do
    key=$(awk -F= '{print $1}' <<< "$line")
    value=$(awk -F= '{print $2}' <<< "$line")
    sed -i 's|<'"$key"'>|'"$value"'|g' files/deploy/haproxy.cfg
done < vars.sh

## Generate SSH key
echo "Generating SSH Key..."
FILE=files/deploy/id_rsa
if [ -f "$FILE" ]; then
    echo "$FILE exists. No need to generate SSH key."
else 
    echo "$FILE does not exist. Generating new SSH key."
    ssh-keygen -t rsa -b 4096 -f files/deploy/id_rsa -N ''
fi

##  Prerequisites on each server
echo "Installing Prereqs..."
ssh -o "StrictHostKeyChecking no" -i $SSH_KEY $USER@$PROXY_IP 'bash -s' < scripts/prereqs.sh &
ssh -o "StrictHostKeyChecking no" -i $SSH_KEY $USER@$LAB_SERVER_IP 'bash -s' < scripts/prereqs.sh &
wait

## Copy files to remote hosts
scp -i $SSH_KEY files/deploy/rancher-docker-compose.yaml $USER@$LAB_SERVER_IP:/alphabravo/misc/rancher/docker-compose.yaml
scp -i $SSH_KEY files/deploy/portainer-docker-compose.yaml $USER@$LAB_SERVER_IP:/alphabravo/misc/portainer/docker-compose.yaml
scp -i $SSH_KEY files/deploy/portainer-password.txt $USER@$LAB_SERVER_IP:/alphabravo/misc/portainer/portainer-password.txt
scp -i $SSH_KEY files/settings.json $USER@$LAB_SERVER_IP:/alphabravo/misc/code-server/User/settings.json
scp -i $SSH_KEY files/codelab.zip $USER@$LAB_SERVER_IP:/alphabravo/misc/code-server/codelab.zip
scp -i $SSH_KEY files/deploy/id_rsa.pub $USER@$LAB_SERVER_IP:~/.ssh/id_rsa.pub
scp -i $SSH_KEY files/le-prod-ca.pem $USER@$PROXY_IP:/alphabravo/misc/certs/ca.pem
scp -i $SSH_KEY files/deploy/haproxy.cfg $USER@$PROXY_IP:/tmp/haproxy.cfg
scp -i $SSH_KEY files/deploy/id_rsa $USER@$PROXY_IP:~/.ssh/id_rsa

## Run remote commands to configure servers
ssh -o "StrictHostKeyChecking no" -i $SSH_KEY $USER@$LAB_SERVER_IP 'cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys'

## Install configs on each server
echo "Installing Proxy configs..."
ssh -o "StrictHostKeyChecking no" -i $SSH_KEY $USER@$PROXY_IP 'bash -s' < scripts/deploy/proxy.sh

echo "Installing Lab-Server configs..."
ssh -o "StrictHostKeyChecking no" -i $SSH_KEY $USER@$LAB_SERVER_IP 'bash -s' < scripts/deploy/lab-server.sh

## Print Server Information and Links
touch ./server-details.txt
echo -----------------------------------------------
echo -e ${G}Install is complete. Please use the below information to access your environment.${E} | tee ./server-details.txt
echo -e ${G}-----Code Server Details-----${E}
echo -e ${G}Code Server UI:${E} https://code.$PROXY_IP.nip.io | tee -a ./server-details.txt
echo -e ${G}Code Server Login${E} $CODE_PASSWORD | tee -a ./server-details.txt
echo -e ${G}-----Rancher Details-----${E}
echo -e ${G}Rancher UI:${E} https://rancher.$PROXY_IP.nip.io | tee -a ./server-details.txt
echo -e ${G}Rancher Login:${E} admin/$RANCHER_PASSWORD | tee -a ./server-details.txt
echo -e ${G}-----Portainer Details-----${E}
echo -e ${G}Portainer UI:${E} https://portainer.$PROXY_IP.nip.io | tee -a ./server-details.txt
echo -e ${G}Portainer Login:${E} admin/$PORTAINER_PASSWORD | tee -a ./server-details.txt
echo -e ${G}-----Proxy Status Page Details - Use For Troubleshooting-----${E}
echo -e ${G}HAProxy UI:${E} https://$PROXY_IP.nip.io/stats/ | tee -a ./server-details.txt
echo -e ${G}HAProxy Login:${E} admin/$HAPROXY_PASSWORD | tee -a ./server-details.txt
echo Details above are saved to the file at ./server-details.txt
echo -----------------------------------------------
