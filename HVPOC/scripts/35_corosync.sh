# Run on all nodes
sudo bash -c 'cat << EOF > /etc/corosync/corosync.conf
totem {
    version: 2
    cluster_name: cluster
    transport: knet
    crypto_cipher: none
    crypto_hash: none
}

nodelist {
    node {
        ring0_addr: 192.168.10.10
        ring1_addr: 172.16.0.10
        nodeid: 1
        name: ubu01
    }
    node {
        ring0_addr: 192.168.10.20
        ring1_addr: 172.16.0.20
        nodeid: 2
        name: ubu02
    }
    node {
        ring0_addr: 192.168.10.30
        ring1_addr: 172.16.0.30
        nodeid: 3
        name: ubu03
    }
}

quorum {
    provider: corosync_votequorum
}

logging {
    to_syslog: yes
}
EOF'

sudo systemctl start pacemaker
sudo systemctl start corosync