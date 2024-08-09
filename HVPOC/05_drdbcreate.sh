#/bin/bash
sudo pvcreate /dev/sdb
sudo vgcreate vgdrdb /dev/sdb
sudo lvcreate -l 100%FREE -n lvdrdb vgdrdb

sudo mkdir -p /nfsshare/exports/HA
sudo chmod 777 -R /nfsshare
sudo mkdir -p /srv/drbd-nfs/nfstest/

sudo bash -c 'cat <<EOF > /etc/drbd.d/nfs.res
resource ha_nfs {
  device /dev/drbd1003;
  disk /dev/vgdrdb/lvdrdb;
  meta-disk internal;
  options {
    on-no-quorum suspend-io;
    quorum majority;
  }
  net {
    protocol C;
    timeout 10;
    ko-count 1;
    ping-int 1;
  }
  connection-mesh {
    hosts ubu01 ubu02 ubu03;
  }
  on ubu01 {
    address 192.168.10.10:7003;
    node-id 0;
    }
    on ubu02 {
    address 192.168.10.20:7003;
    node-id 1;
    }
    on ubu03 {
    disk none;
    address 192.168.10.30:7003;
    node-id 2;
    }
}
EOF'