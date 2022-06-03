#!/bin/bash

## Add your IPs and User below
PROXY_IP=
LAB_SERVER_IP=
USER=

## Generating SSH Key
echo "Generating SSH Key..."
mkdir lab_tmp
ssh-keygen -t rsa -b 4096 -f ./lab_tmp/id_rsa -N ''
chmod 0600 ./lab_tmp/id_rsa

## Copying SSH key to lab server and adding to authorized keys
echo "Copying SSH key to lab server and adding to authorized keys..."
scp ./lab_tmp/id_rsa.pub $USER@$PROXY_IP:~/.ssh/id_rsa.pub
scp ./lab_tmp/id_rsa.pub $USER@$LAB_SERVER_IP:~/.ssh/id_rsa.pub
ssh $USER@$PROXY_IP 'cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys'
ssh $USER@$LAB_SERVER_IP 'cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys'
