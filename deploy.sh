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

## Update scripts with variables from vars
cp scripts/templates/lab-server.sh.tmpl scripts/deploy/lab-server.sh
while read line || [[ -n "$line" ]]
do
    key=$(awk -F= '{print $1}' <<< "$line")
    value=$(awk -F= '{print $2}' <<< "$line")
    sed -i 's|$'"$key"'|'"$value"'|g' scripts/deploy/lab-server.sh
done < vars.sh

## Update Rancher Docker Compose file from vars
cp files/templates/rancher-docker-compose.yaml.tmpl files/deploy/rancher-docker-compose.yaml
while read line || [[ -n "$line" ]]
do
    key=$(awk -F= '{print $1}' <<< "$line")
    value=$(awk -F= '{print $2}' <<< "$line")
    sed -i 's|$'"$key"'|'"$value"'|g' files/deploy/rancher-docker-compose.yaml
done < vars.sh

## Update proxy.sh file from vars
cp scripts/templates/proxy.sh.tmpl scripts/deploy/proxy.sh
while read line || [[ -n "$line" ]]
do
    key=$(awk -F= '{print $1}' <<< "$line")
    value=$(awk -F= '{print $2}' <<< "$line")
    sed -i 's|$'"$key"'|'"$value"'|g' scripts/deploy/proxy.sh
done < vars.sh

## Update Portainer Docker Compose file from vars
cp files/templates/portainer-docker-compose.yaml.tmpl files/deploy/portainer-docker-compose.yaml
while read line || [[ -n "$line" ]]
do
    key=$(awk -F= '{print $1}' <<< "$line")
    value=$(awk -F= '{print $2}' <<< "$line")
    sed -i 's|$'"$key"'|'"$value"'|g' files/deploy/portainer-docker-compose.yaml
done < vars.sh

## Update Portainer password file from vars
cp files/templates/portainer-password.txt.tmpl files/deploy/portainer-password.txt
while read line || [[ -n "$line" ]]
do
    key=$(awk -F= '{print $1}' <<< "$line")
    value=$(awk -F= '{print $2}' <<< "$line")
    sed -i 's|$'"$key"'|'"$value"'|g' files/deploy/portainer-password.txt
done < vars.sh

## Update haproxy file from vars
cp files/templates/haproxy.cfg.tmpl files/deploy/haproxy.cfg
while read line || [[ -n "$line" ]]
do
    key=$(awk -F= '{print $1}' <<< "$line")
    value=$(awk -F= '{print $2}' <<< "$line")
    sed -i 's|$'"$key"'|'"$value"'|g' files/deploy/haproxy.cfg
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
ssh -o "StrictHostKeyChecking no" -i $ssh_key $user@$proxy_ip 'bash -s' < scripts/prereqs.sh &
ssh -o "StrictHostKeyChecking no" -i $ssh_key $user@$lab_server_ip 'bash -s' < scripts/prereqs.sh &
wait

## Copy files to remote hosts
scp -i $ssh_key files/deploy/rancher-docker-compose.yaml $user@$lab_server_ip:/alphabravo/misc/rancher/docker-compose.yaml
scp -i $ssh_key files/deploy/portainer-docker-compose.yaml $user@$lab_server_ip:/alphabravo/misc/portainer/docker-compose.yaml
scp -i $ssh_key files/deploy/portainer-password.txt $user@$lab_server_ip:/alphabravo/misc/portainer/portainer-password.txt
scp -i $ssh_key files/settings.json $user@$lab_server_ip:/alphabravo/misc/code-server/User/settings.json
scp -i $ssh_key files/codelab.zip $user@$lab_server_ip:/alphabravo/misc/code-server/codelab.zip
scp -i $ssh_key files/deploy/id_rsa.pub $user@$lab_server_ip:/root/.ssh/id_rsa.pub
ssh -o "StrictHostKeyChecking no" -i $ssh_key $user@$lab_server_ip 'cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys'
scp -i $ssh_key files/deploy/haproxy.cfg $user@$proxy_ip:/tmp/haproxy.cfg
scp -i $ssh_key files/deploy/id_rsa $user@$proxy_ip:/root/.ssh/id_rsa

## Install configs on each server
echo "Installing Proxy configs..."
ssh -o "StrictHostKeyChecking no" -i $ssh_key $user@$proxy_ip 'bash -s' < scripts/deploy/proxy.sh

echo "Installing Lab-Server configs..."
ssh -o "StrictHostKeyChecking no" -i $ssh_key $user@$lab_server_ip 'bash -s' < scripts/deploy/lab-server.sh

## Print Server Information and Links
touch ./server-details.txt
echo -----------------------------------------------
echo -e ${G}Install is complete. Please use the below information to access your environment.${E} | tee ./server-details.txt
echo -e ${G}Please update your DNS or Hosts file to point https://$1 to the IP of this server $NODE_IP.${E} | tee -a ./server-details.txt
echo -e ${G}-----Code Server Details-----${E}
echo -e ${G}Code Server UI:${E} https://code.$proxy_ip.nip.io | tee -a ./server-details.txt
echo -e ${G}Code Server Login${E} $code_password | tee -a ./server-details.txt
echo -e ${G}-----Rancher Details-----${E}
echo -e ${G}Rancher UI:${E} https://rancher.$proxy_ip.nip.io | tee -a ./server-details.txt
echo -e ${G}Rancher Login:${E} admin/$rancher_password | tee -a ./server-details.txt
echo -e ${G}-----Portainer Details-----${E}
echo -e ${G}Portainer UI:${E} https://portainer.$proxy_ip.nip.io | tee -a ./server-details.txt
echo -e ${G}Portainer Login:${E} admin/$portainer_password | tee -a ./server-details.txt
echo -e ${G}-----Proxy Status Page Details - Use For Troubleshooting-----${E}
echo -e ${G}HAProxy UI:${E} https://$proxy_ip.nip.io/stats/ | tee -a ./server-details.txt
echo -e ${G}HAProxy Login:${E} admin/$haproxy_password | tee -a ./server-details.txt
echo Details above are saved to the file at ./server-details.txt
echo -----------------------------------------------
