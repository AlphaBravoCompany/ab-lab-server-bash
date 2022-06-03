## Virtualbox VM Setup

The following instructions will assist you in setting up local virtualbox VMs.

## Setting up 2 Ubuntu 20.04 VMs

You will need 2 Ubuntu 20.04 VMs for this.

- (1x) 2vCPU and 2GB RAM
- (1x) 8vCPU and 16GB RAM

Follow the excellent instructions here for downloading Ubuntu Server and setting up the systems: https://hibbard.eu/install-ubuntu-virtual-box/

You can stop at the `Generate and Install a SSH Key Pair` section. We have a script that you can run in WSL, Mac or Linux to create and copy the SSH keys to the hosts.

## Passwordless Sudo

Next we need to add you user as a passwordless sudo user. This is important for the Proxy and Lab-Server setup scripts to work properly.

1. Perform the following steps on both servers
2. SSH into your server
3. Type `sudo visudo` and enter your password
4. Add `YOURUSER ALL=(ALL:ALL) NOPASSWD:ALL` to the bottom of the file, replacing YOURUSER with your actual username. Hit `Ctrl + X` and `Y` to save.
5. Logout and log back in
6. Run `sudo apt update` and make sure you are not prompted for a password

## Adding SSH Keys

1. Update the `vmsetup/install-keys.sh` script with your `PROXY_IP`, `LAB_SERVER_IP` and `USER` save the file
2. Run `./vmsetup/install-keys.sh` and the file will generate SSH keys and copy them to your servers for you.

## Private Key location
Your keys will for your servers will now be in `vmsetup/lab_tmp` and you can use `vmsetup/lab_tmp/id_rsa` as your key path in `vars.sh`.

## Time to deploy

You should now have 2 servers all prepared to have the lab materials deployed. Please proceed to the root of this repo and follow the installation instructions in the `README.md` file there.