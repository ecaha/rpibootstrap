sudo add-apt-repository ppa:linbit/linbit-drbd9-stack -y
sudo apt update -y
sudo apt-get upgrade -y

# Install DRBD
sudo apt install drbd-utils drbd-dkms --no-install-recommends --no-install-suggests -y

# Install pacemaker and corosync
sudo apt install pacemaker corosync pcs -y

# Install NFS
sudo apt install nfs-kernel-server -y

# Install resource agents
sudo apt install resource-agents-extra  -y


# sudo systemctl start pcsd

sudo systemctl enable pacemaker corosync # pcsd



# fence-agents

