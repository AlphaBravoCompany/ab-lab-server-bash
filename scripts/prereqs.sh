#!/bin/bash

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

## Update OS
sudo apt update  > /dev/null 2>&1
sudo apt upgrade -y  > /dev/null 2>&1

## Install Prereqs
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release unzip python3-pip \
software-properties-common haveged bash-completion jq zsh zsh-autosuggestions libnss3-tools certbot > /dev/null 2>&1

## Create user
# echo "Creating AlphaBravo user..."
# sudo adduser alphabravo
# sudo usermod -aG sudo alphabravo
# echo '$ a alphabravo ALL=(ALL:ALL) NOPASSWD: ALL' | EDITOR="sed -f- -i" visudo

## Change Shell
echo "Installing zsh and oh-my-zsh..."
FILE=$HOME/.oh-my-zsh/oh-my-zsh.sh
if [ -f "$FILE" ]; then
    echo "$FILE exists. No need to install oh-my-zsh again."
else
    mkdir -p /alphabravo/misc/dotfiles
    git clone https://github.com/AlphaBravoCompany/ab-dotfiles.git /alphabravo/misc/dotfiles/
    chmod +x /alphabravo/misc/dotfiles/install.sh
    cd /alphabravo/misc/dotfiles
    ./install.sh
    cd ~
fi

## Docker Things ##
## Installing Docker Engine
echo "Installing Docker Engine..."
FILE=/usr/bin/docker
if [ -f "$FILE" ]; then
    echo "$FILE exists. No need to install Docker again."
else 
    echo "$FILE does not exist. Installing Docker."
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh > /dev/null 2>&1
    sudo sh /tmp/get-docker.sh > /dev/null 2>&1
fi

## Installing Docker Compose
echo "Installing Docker Compose..."
curl -SL https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose > /dev/null 2>&1
sudo chmod +x /usr/local/bin/docker-compose > /dev/null 2>&1

mkdir -p /alphabravo/misc/rancher
mkdir -p /alphabravo/misc/registry
mkdir -p /alphabravo/misc/portainer
mkdir -p /alphabravo/misc/haproxy
mkdir -p /alphabravo/misc/certs
mkdir -p /alphabravo/misc/code-server
mkdir -p /alphabravo/misc/code-server/User
mkdir -p /alphabravo/labs
mkdir -p /alphabravo/labs/public
mkdir -p /alphabravo/labs/private

## Install mkcert
curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
chmod +x mkcert-v*-linux-amd64
sudo cp mkcert-v*-linux-amd64 /usr/local/bin/mkcert