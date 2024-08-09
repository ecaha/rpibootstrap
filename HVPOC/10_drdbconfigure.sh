#run on all disk nodes
sudo drbdadm create-md ha_nfs
#run on all nodes 
sudo drbdadm up ha_nfs

#run on one disk node
sudo drbdadm new-current-uuid --clear-bitmap ha_nfs/0

sudo drbdadm primary --force ha_nfs
sudo mkfs.ext4 /dev/drbd1003

## check status
sudo drbdadm status