#run on all nodes
sudo bash -c 'echo "hacluster:Telatko123456!" |chpasswd'

#run omn one node
sudo pcs host auth ubu01 ubu02 ubu03 -u hacluster -p Telatko123456!

sudo pcs cluster setup nfscluster ubu01 ubu02 ubu03 --force

sudo pcs cluster start --all