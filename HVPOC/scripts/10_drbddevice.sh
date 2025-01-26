# /bin/bash
sudo pvcreate /dev/sdb
sudo vgcreate vgdrdb /dev/sdb
sudo lvcreate -l 100%FREE -n lvdrdb vgdrdb

sudo mkdir -p /nfsshare/exports/HA
sudo chmod 777 -R /nfsshare
sudo mkdir -p /srv/drbd-nfs/nfstest/