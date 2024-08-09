Configure node names:

This code block configures the names of the nodes in the cluster using the sudo crm configure node command. In this case, three nodes are configured with the names ubu01, ubu02, and ubu03.
Configure resource stickiness:

This code block sets the resource stickiness value using the sudo crm configure rsc_defaults command. Resource stickiness determines how likely a resource is to stay on a particular node when there are failures or changes in the cluster. In this case, the resource stickiness is set to a value of 200.
Configure virtual IP address:

This code block configures a virtual IP address using the sudo crm configure primitive command. The virtual IP address is defined as p_virtip and is assigned the IP address 192.168.10.100 with a subnet mask of 24. The op parameters specify the monitoring interval, timeout, and start/stop intervals for the virtual IP address resource.
Configure DRBD resource for high availability NFS:

This code block configures a DRBD (Distributed Replicated Block Device) resource for high availability NFS (Network File System) using the sudo crm configure primitive command. The DRBD resource is defined as p_drbd_ha_nfs and is configured with the ocf:linbit:drbd resource agent. The op parameters specify the monitoring timeout, interval, and the roles of the resource (Slave and Master).
Configure NFS export for HA:

This code block configures an NFS export for high availability using the sudo crm configure primitive command. The NFS export is defined as p_expfs_nfsshare_exports_HA and is configured with the exportfs resource agent. The params specify the clientspec, directory, fsid, and other options for the NFS export. The op parameters specify the monitoring interval, timeout, and start/stop intervals for the NFS export resource.
Configure filesystem for NFS export:

This code block configures a filesystem for the NFS export using the sudo crm configure primitive command. The filesystem is defined as p_fs_nfsshare_exports_HA and is configured with the Filesystem resource agent. The params specify the device, directory, fstype, and other options for the filesystem. The op parameters specify the monitoring interval, timeout, and start/stop intervals for the filesystem resource.
Configure NFS server:

This code block configures an NFS server using the sudo crm configure primitive command. The NFS server is defined as p_nfsserver and is configured with the nfsserver resource agent.
Configure port blocking for NFS:

This code block configures port blocking for NFS using the sudo crm configure primitive command. The port blocking is defined as p_pb_block and is configured with the portblock resource agent. The params specify the action, IP address, port number, and protocol for the port blocking.
Configure port unblocking for NFS:

This code block configures port unblocking for NFS using the sudo crm configure primitive command. The port unblocking is defined as p_pb_unblock and is configured with the portblock resource agent. The params specify the action, IP address, port number, tickle directory, and other options for the port unblocking. The op parameters specify the monitoring interval and timeout for the port unblocking resource.
Configure master/slave setup for DRBD resource:

This code block configures a master/slave setup for the DRBD resource using the sudo crm configure ms command. The master/slave setup is defined as ms_drbd_ha_nfs and is based on the p_drbd_ha_nfs resource. The meta parameters specify the maximum number of masters, maximum number of master nodes, maximum number of clones, and whether notifications should be enabled.
Configure group for NFS resources:

This code block configures a group for the NFS resources using the sudo crm configure group command. The group is defined as g_nfs and includes the resources p_pb_block, p_virtip, p_fs_nfsshare_exports_HA, p_nfsserver, p_expfs_nfsshare_exports_HA, and p_pb_unblock. This ensures that these resources are managed together as a group.
Configure colocation constraint for NFS resources:

This code block configures a colocation constraint for the NFS resources using the sudo crm configure colocation command. The colocation constraint is defined as co_ha_nfs and specifies that the group g_nfs should be started on the same node as the ms_drbd_ha_nfs resource when it is in the Master role.
Configure order constraint for DRBD promotion before NFS start:

This code block configures an order constraint for the DRBD promotion before the NFS start using the sudo crm configure order command. The order constraint is defined as o_ms_drbd_ha_nfs-before-g_nfs and specifies that the ms_drbd_ha_nfs resource should be promoted to the Master role before the g_nfs group is started.
Configure cluster properties:

This code block configures cluster properties using the sudo crm configure property command. The cluster properties include cib-bootstrap-options, have-watchdog, cluster-infrastructure, cluster-name, and stonith-enabled. In this case, the have-watchdog property is set to false, the cluster-infrastructure property is set to corosync, the cluster-name property is set to nfscluster, and the stonith-enabled property is set to false.
These code blocks configure various aspects of a pacemaker cluster for high availability NFS. Each block sets up different resources, constraints, and properties to ensure the availability and reliability of the NFS service.

add lines above to code markdown formatted

