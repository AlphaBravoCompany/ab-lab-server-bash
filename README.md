# AB Lab Server Bash

This script uses a bash script with user provided variables to deploy the AlphaBravo lab server used for training.

## Requirements

- 2x Ubuntu Server 20.04+ on AMD64 compatible machine
- 1x 1vCPU and 1G RAM (Proxy)
- 1x 8vCPU and 16G RAM (Lab Server)
- SSH Access and key to lab servers

## Recommendations

If you do not have local VMs or a corporate account you can deploy the labs to, we recommend a few lower cost providers you can use for your training lab servers. Some links may be referral links that gives AlphaBravo credits when you sign up for a new account.

- Hetzner - https://hetzner.cloud/?ref=JRGtolHM4Qdb
- Contabo - https://contabo.com/en/
- DigitalOcean - https://m.do.co/c/c391b7f3c086
- Linode - https://www.linode.com/

## Local Server Setup

You can use a platform like VirtualBox or VMWare Workstation to deploy VMs on your local machine. The tool uses a locally generated self signed certificate so it does not need to be internet connected. 

You will need to configure SSH access to these nodes and have a key handy. Instructions here: https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-on-ubuntu-20-04 

- VirtualBox: https://www.virtualbox.org/
- VMWare Workstation: https://www.vmware.com/products/workstation-player.html 

## Cloud Server Setup

You can use any cloud host you like for the servers. It does not need to be publically exposed, but does need internet access (egress) to download the materials to the hosts. AWS, GCP, Azure, Hetzner, Contabo, DigitalOcean, Linode, etc should all work.

Make sure you add an SSH public key to the platform and use the related private key to access the systems with the install script.

## Installation

1. Clone repo
2. `cd ab-lab-server-bash`
3. Copy `vars.sh.tmpl` to `vars.sh` - `cp vars.sh.tmpl vars.sh`
3. Modify `vars.sh` with your own variables (server IPs, passwords, key path, etc)
4. Run `chmod +x deploy.sh`
5. Run `./deploy.sh`
6. When the script completes, details about how to access your environment will be output on the screen and saved to `server-details.txt` file.

## About Alphabravo

![](assets/ablogo.png)

**AlphaBravo** provides products, services, and training for Cybersecurity, Kubernetes, Cloud, and DevSecOps. AlphaBravo is a Rancher training and services partner.

Contact **AB** today to learn how we can help you.

* **Web:** https://alphabravo.io
* **Email:** info@alphabravo.io
* **Phone:** 301-337-8141
