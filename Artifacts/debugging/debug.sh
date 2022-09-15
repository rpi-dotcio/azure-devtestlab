#!/bin/bash
#
# Script to debugging and testing
#
# NOTE: Intended for use by the Azure DevTest Lab artifact system.
#

firstUser=$(id -nu 1000)

#main---------------------------------------------------------------------------
echo "alias cls='clear'" >> /etc/bash.bashrc
echo "alias ..='cd ..'" >> /etc/bash.bashrc
echo "alias l='ls -alF'" >> /etc/bash.bashrc
echo "alias dc='docker-compose'" >> /etc/bash.bashrc
eco "alias dcl= dc exec login bash" >> /etc/bash.bashrc
source /etc/bash.bashrc
apt -y update && apt -y upgrade && apt -y install curl gcc make docker-compose wget
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
curl -sSL https://get.docker.com/ | sudo bash
rm -rf /usr/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
usermod -a -G docker $firstUser

# Modify system settings for Slurm v 22.05
echo "
net.core.somaxconn=15000
net.ipv4.tcp_max_syn_backlog=4096
net.core.netdev_max_backlog=1000
fs.file-max=992832
# Force gc to clean-up quickly
net.ipv4.neigh.default.gc_interval = 3600
# Set ARP cache entry timeout
net.ipv4.neigh.default.gc_stale_time = 3600
# Setup DNS threshold for arp
net.ipv4.neigh.default.gc_thresh3 = 8096
net.ipv4.neigh.default.gc_thresh2 = 4048
net.ipv4.neigh.default.gc_thresh1 = 1024
# Increase map count for elasticsearch
vm.max_map_count=262144
# Avoid running out of file descriptors
fs.file-max=10000000
fs.inotify.max_user_instances=65535
fs.inotify.max_user_watches=1048576" >> /etc/sysctl.conf

git clone --depth 1 --single-branch -b slurm-22.05 https://gitlab.com/SchedMD/training/docker-scale-out.git /home/$firstUser/docker-scale-out
chown $firstUser:$firstUser -R /home/$firstUser/docker-scale-out
sed -i 's/^FROM alpine$/FROM alpine:3.15/g' /home/$firstUser/docker-scale-out/proxy/Dockerfile
echo "cd docker-scale-out" >> /home/$firstUser/.bashrc
runuser -l  $firstUser -c 'cd ~/docker-scale-out && make build'