# Configure cluster properties
sudo pcs property set stonith-enabled=false

# Configure resource stickiness
sudo pcs resource defaults update resource-stickiness=200

# Configure virtual IP address
sudo pcs resource create p_virtip ocf:heartbeat:IPaddr2 \
    ip=192.168.10.100 \
    cidr_netmask=24 \
    op monitor interval=0s timeout=40s \
    op start interval=0s timeout=20s \
    op stop interval=0s timeout=20s

# Configure DRBD resource for high availability NFS
sudo pcs resource create p_drbd_ha_nfs ocf:linbit:drbd \
    drbd_resource=ha_nfs \
    op monitor timeout=20 interval=21 role=Unpromoted \
    op monitor timeout=20 interval=20 role=Promoted

# Configure NFS export for HA
sudo pcs resource create p_expfs_nfsshare_exports_HA ocf:heartbeat:exportfs \
    clientspec="192.168.10.0/24" \
    directory="/nfsshare/exports/HA" \
    fsid=1003 unlock_on_stop=1 options=rw \
    op monitor interval=15s timeout=40s OCF_CHECK_LEVEL=0 \
    op start interval=0s timeout=40s \
    op stop interval=0s timeout=120s

# Configure filesystem for NFS export
sudo pcs resource create p_fs_nfsshare_exports_HA ocf:heartbeat:Filesystem \
    device="/dev/drbd1003" \
    directory="/nfsshare/exports/HA" \
    fstype=ext4 \
    run_fsck=no \
    op monitor interval=15s timeout=40s OCF_CHECK_LEVEL=0 \
    op start interval=0s timeout=60s \
    op stop interval=0s timeout=60s

# Configure NFS server
sudo pcs resource create p_nfsserver ocf:heartbeat:nfsserver

# Configure port blocking for NFS
sudo pcs resource create p_pb_block ocf:heartbeat:portblock \
    action=block \
    ip=192.168.10.100 \
    portno=2049 \
    protocol=tcp

# Configure port unblocking for NFS
sudo pcs resource create p_pb_unblock ocf:heartbeat:portblock \
    action=unblock \
    ip=192.168.10.100 \
    portno=2049 \
    tickle_dir="/srv/drbd-nfs/nfstest/.tickle" \
    reset_local_on_unblock_stop=1 protocol=tcp \
    op monitor interval=10s timeout=20s

# Configure master/slave setup for DRBD resource
sudo pcs resource create ms_drbd_ha_nfs ocf:linbit:drbd \
    drbd_resource=p_drbd_ha_nfs \
    op monitor timeout=20 interval=21 role=Unpromoted \
    op monitor timeout=20 interval=20 role=Promoted
sudo pcs resource promotable ms_drbd_ha_nfs \
           promoted-max=1 promoted-node-max=1 \
           clone-max=3 clone-node-max=1 notify=true

# Configure group for NFS resources
sudo pcs resource group add g_nfs p_pb_block p_virtip p_fs_nfsshare_exports_HA \
    p_nfsserver p_expfs_nfsshare_exports_HA p_pb_unblock

# Configure colocation constraint for NFS resources
sudo pcs constraint colocation add g_nfs with ms_drbd_ha_nfs INFINITY with-rsc-role=Master

# Configure order constraint for DRBD promotion before NFS start
sudo pcs constraint order promote ms_drbd_ha_nfs then start g_nfs
