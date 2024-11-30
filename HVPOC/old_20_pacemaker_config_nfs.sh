

# Configure node names
sudo crm configure node 1: ubu01
sudo crm configure node 2: ubu02
sudo crm configure node 3: ubu03

# Configure cluster properties
sudo crm configure property cib-bootstrap-options: \
        have-watchdog=false \
        cluster-infrastructure=corosync \
        cluster-name=nfscluster \
        stonith-enabled=false

# Configure resource stickiness
sudo crm configure rsc_defaults resource-stickiness="200"

# Configure virtual IP address
sudo crm configure primitive p_virtip IPaddr2 \
        params \
            ip=192.168.10.100 \
            cidr_netmask=24 \
        op monitor interval=0s timeout=40s \
        op start interval=0s timeout=20s \
        op stop interval=0s timeout=20s


# Configure DRBD resource for high availability NFS
sudo crm configure primitive p_drbd_ha_nfs ocf:linbit:drbd \
        params \
            drbd_resource=ha_nfs \
        op monitor timeout=20 interval=21 role=Slave \
        op monitor timeout=20 interval=20 role=Master

# Configure NFS export for HA
sudo crm configure primitive p_expfs_nfsshare_exports_HA exportfs \
        params \
            clientspec="192.168.10.0/24" \
            directory="/nfsshare/exports/HA" \
            fsid=1003 unlock_on_stop=1 options=rw \
        op monitor interval=15s timeout=40s \
        op_params OCF_CHECK_LEVEL=0 \
        op start interval=0s timeout=40s \
        op stop interval=0s timeout=120s

# Configure filesystem for NFS export
sudo crm configure primitive p_fs_nfsshare_exports_HA Filesystem \
        params \
            device="/dev/drbd1003" \
            directory="/nfsshare/exports/HA" \
            fstype=ext4 \
            run_fsck=no \
        op monitor interval=15s timeout=40s \
        op_params OCF_CHECK_LEVEL=0 \
        op start interval=0s timeout=60s \
        op stop interval=0s timeout=60s

# Configure NFS server
sudo crm configure primitive p_nfsserver nfsserver

# Configure port blocking for NFS
sudo crm configure primitive p_pb_block portblock \
        params \
            action=block \
            ip=192.168.10.100 \
            portno=2049 \
            protocol=tcp

# Configure port unblocking for NFS
sudo crm configure primitive p_pb_unblock portblock \
        params \
            action=unblock \
            ip=192.168.10.100 \
            portno=2049 \
            tickle_dir="/srv/drbd-nfs/nfstest/.tickle" \
            reset_local_on_unblock_stop=1 protocol=tcp \
        op monitor interval=10s timeout=20s

# Configure master/slave setup for DRBD resource
sudo crm configure ms ms_drbd_ha_nfs p_drbd_ha_nfs \
        meta master-max=1 master-node-max=1 \
        clone-node-max=1 clone-max=3 notify=true

# Configure group for NFS resources
sudo crm configure group g_nfs p_pb_block p_virtip p_fs_nfsshare_exports_HA \
        p_nfsserver p_expfs_nfsshare_exports_HA p_pb_unblock

# Configure colocation constraint for NFS resources
sudo crm configure colocation co_ha_nfs inf: \
        g_nfs:Started ms_drbd_ha_nfs:Master

# Configure order constraint for DRBD promotion before NFS start
sudo crm configure order o_ms_drbd_ha_nfs-before-g_nfs ms_drbd_ha_nfs:promote g_nfs:start

