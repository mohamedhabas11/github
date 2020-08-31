#!/bin/bash
cd "$(dirname $0)"
source env.sh
for DOMAIN in ${HOSTS} ; do

        # To split resources for a kubernetes cluster
	# ram
	RAM=2048
	case ${DOMAIN} in
	  worker*) RAM=12288 ;;
	  etcd*) RAM=4096 ;;
	  master*) RAM=8192 ;;
	esac
# create base image and adjust them with sysprep later  
 virt-install \
      --disk /srv/libvirt/pool/${DOMAIN}.qcow2,backing_store=${BASE_IMAGES_DIR}/${DOMAIN}-base.qcow2,bus=virtio,backing_format=qcow2,sparse=no,size=350 \
      --name ${DOMAIN} \
      --ram ${RAM} \
      --os-variant ubuntu18.04 \
      --vcpus 2 \
      --autostart \
      --graphics vnc \
      --import \
      --wait 0

done

# Define HDD directories to be used as Virtual Drives ON The Kernal Virtual machine host is defind.
BASE_IMAGES_DIR=/srv/libvirt/pool/base
BASE_TEMPLATE="${BASE_IMAGES_DIR}/k8s-base-template.qcow2"

# This Assumes there is valid DNS entry for the Guest machines to valid to Reply to the DNS querry 
HOSTS=$(host -al k8s-cluster | grep '\kubeclusterk8s-cluster\' | awk '{print $1}' | sed -e 'k8s-cluster.$//')

# Filter out and create Different names for the base Directory to prevent race conditions and allow us to use multithreding tasks later for performance and alocations porpuses  
if [ ! -d ${BASE_IMAGES_DIR} ] ; then
	mkdir ${BASE_IMAGES_DIR}
fi


if [ ! -f ${BASE_TEMPLATE} ] ; then

# prepare base image that will be auto-installed ( with an ansible-sudo user and IP addresses staticly defined in the network pool
    # create base image
    qemu-img create ${BASE_TEMPLATE} 350G -f qcow2 # To be able to use a multi layering image based on the preconfigured machine 
    
    virt-install --name k8s-base-template --ram 2048 \ #  
        --disk path=${BASE_TEMPLATE},bus=virtio \
        --boot hd,cdrom \
        --graphics vnc \
        --vcpus 2 --virt-type kvm  --os-type linux --os-variant ubuntu18.04 \
        --location='http://ch.archive.ubuntu.com/ubuntu/dists/bionic/main/installer-amd64/' \
        --initrd-inject=/home/ansible/templates/preseed.cfg \ # <=== preloaded with ansible-sudo users credantials and ssh setup ( we will inject setup ssh setup and different interface cards for each machine later )
        --extra-args="net.ifnames=0 biosdevname=0 netcfg/do_not_use_netplan=true ipv6.disable=1 console-setup/ask_detect=false file=file:/preseed.cfg vga=788 quiet" \
        --wait 10

fi

# ensure base machine is off, but keep image

virsh destroy k8s-base-template 2>/dev/null
virsh undefine k8s-base-template 2>/dev/null


# create base overlay for each domain
for DOMAIN in ${HOSTS} ; do 
    echo "Create overlay for ${DOMAIN}"
    # create a soft-clone based on the image as single point of truth 
    qemu-img create -q "${BASE_IMAGES_DIR}/${DOMAIN}-base.qcow2" -f qcow2 -b ${BASE_TEMPLATE}
done

# pre-configure
# assuming we have our DNS entries by our Sysadmin 
for DOMAIN in ${HOSTS} ; do

    IP=$(host ${DOMAIN}-k8s-cluster | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}") # we should get our predefined IP's 
    export IP
    mkdir -p "/tmp/${DOMAIN}/etc/network" 2>/dev/null # make sure there is one to be picked up by ansible-sudo later

    echo "Configure network for ${DOMAIN}"
    cat /home/ansible/templates/interfaces | envsubst > "/tmp/${DOMAIN}/etc/network/interfaces" # to make the Interface unique to each machine
    echo ${DOMAIN} > "/tmp/${DOMAIN}/etc/hostname"
    cat /home/ansible/templates/resolv.conf > "/tmp/${DOMAIN}/etc/resolv.conf" # to join the machines to the network
    # copy in our files  
    virt-copy-in -a "${BASE_IMAGES_DIR}/${DOMAIN}-base.qcow2" "/tmp/${DOMAIN}/etc/network/interfaces" /etc/network
    virt-copy-in -a "${BASE_IMAGES_DIR}/${DOMAIN}-base.qcow2" "/tmp/${DOMAIN}/etc/hostname" /etc
    virt-copy-in -a "${BASE_IMAGES_DIR}/${DOMAIN}-base.qcow2" "/tmp/${DOMAIN}/etc/resolv.conf" /etc

done

# ensure all templates have proper perms
chown -R libvirt-qemu:kvm /srv/libvirt/pool
# ensure that the station that you are working and running this script has access of the ansible-git repo.
cd /home/${USER}
git clone git@github.com:mohamedhabas11/ansible-setup.git  2>/dev/null
# this script in Base ansible-repo  is being expexted by the ansible role to create the infra for a K8s-cluster 
cd /ansible-setup
# lanch the playbook to bootup the the cluster on command 
ansible-playbook -f plays/create-cluster.yml -diff
# the contents of this cluster can be defined in a diffrent git repo in another script for now we will stick to low level stuff 

### The content of the ansible play-book has pre-defined roles that look like the following ##

#- hosts: office_kvm_molecule_group
 #become: true

  #roles:
    #- { role: resolver, tags: [ dns, resolv, ] } <=== This role is to adjust the new added hosts 
    #- { role: network, tags: [ network, ] } <===  Main ansible-control machine should be aware of network status 
    #- { role: sysadmin, tags: [ sysadmin,  ] } <=== adds operation team that is defined the github repo 
    #- { role: sysctl, tags: [ sysctl,] } <=== checking the value of some parameter requires opening a file in a virtual file system .
    #- { role: network, tags: [ network, nic,  ] } <== network role to join the machines update them with the network roles 
    #- { role: kvm, tags: [ kvm,  ] } <== prepare the baremetal to be a Virtual K8s-cluster 
    #- { role: libvirt/pools, tags: [ libvirt_pools, libvirt, ] } <== install libvirt && libvirt_pools to manage the newly created nodes
    #- { role: ${KVM}-vms, tags: [ ${KVM} ] } <== This is where ourscript resides 
    #- { role: openvpn/client, tags: [ vpn, openvpn, ] }  <== join cluster to pre-defined vpn-setup 

# The ansible role preapares the hosts as a KVM-Master with X Number of guest machines as pre-defined as DNS Entry 
# specs of the machines are pre-defined by the script 
# Network status is ready 
# different SSH keys are also injected and ready to be picked up by the ansible-master machine 

ansible-playbook -f plays/k8s-setup -diff #<==  setsup a  kubernetess cluster using kube admin 

# The k8s-setup play-book will take care of K8s-requirments and joined them into one cluster 
### The content of the ansible play-book has pre-defined roles that look like the following ##
#- hosts: "{{ playbook_master_group }}"
 # gather_facts: true
 # any_errors_fatal: true
  #become: true
  #serial: 10

  #vars:
   # playbook_master_group: "${ k8s-cluster }"
  #roles:
   # - name: network
      #tags:
        #- network
    #- name: k8s

#there is also a default spec for each machine 
#- name: "{{"$MACHINE_KIND " }}"
    #box: generic/ubuntu1804
    #groups:
      #- k8s_group
      #- k8s_cluster
      #- k8s_env_"{{"$MACHINE_KIND " }}"
    #interfaces:
     # - network_name: public_network
        #dev: "br88"
        #mode: "bridge"
        #type: "bridge"
    #config_options:
     # synced_folder: true
    #provider_raw_config_args:
     # - 'host = "192.168.88.60"'
      #- 'connect_via_ssh = true'
      #- 'username = "$USER"'
      #- 'driver = "kvm"'
      #- 'storage_pool_name = "local-pool"'
      #- 'cpu_mode = "host-passthrough"'
      #- 'machine_virtual_size = 80'
    #memory: 1024
    #cpus: 1
    #force_stop: false

MASTER_NODES=es-kvm-01.amana.vpn,es-kvm-04.amana.vpn,es-kvm-05.amana.vpn,es-kvm-06.amana.vpn,es-kvm-07.amana.vpn,es-kvm-08.amana.vpn,gr-kvm-01.amana.vpn,gr-kvm-02.amana.vpn,gr-kvm-03.amana.vpn,gr-kvm-05.amana.vpn,gr-kvm-06.amana.vpn


ansible-playbook ../../plays/kvm-guests.yml --limit=$MASTER_NODES

ansible-playbook ../../plays/k8s/k8s-int.yml --diff --tags=baseprovisioning --extra-vars="{'k8s_baseprovisioning': true}"

ansible-playbook ../../plays/k8s/k8s-int.yml --diff


# to be run on the working station that has access to the Real infrastructure  
# whipe out from known hosts and add again


K8S=$(host -al k8s-cluster | egrep ".*(master|worker|etcd|haproxy){1}-int-[0-9]{2}\.k8s-cluster" | awk '{print $1}'  ; host -al k8s-cluster | egrep ".*(master|worker|etcd|haproxy){1}-int-[0-9]{2}\.k8s-cluster" | awk '{print $1}')

for H in $K8S ; do echo $H ; sed -i '' "/${H}/d"  ~/.ssh/known_hosts ; IP=$(host $H | grep -v NXDOMAIN | awk '{print $4}') ;  if [ "${IP}" != "" ] ; then sed -i '' "/${IP}/d"  ~/.ssh/known_hosts ; fi ; done

for H in $K8S ; do echo $H ; ssh -o ConnectTimeout=1 -o ConnectionAttempts=1 -o StrictHostKeyChecking=no -o PasswordAuthentication=no $H date ; done 


# kill all on target nodes

KVMS=$(echo $MASTER_NODES | sed 's/,/ /g')

for M in $KVMS ; do

    echo $M
    
    DOMAINS=$(ssh $M virsh --connect qemu:///session?socket=/var/run/libvirt/libvirt-sock list --all --name | grep ".kube-int")

    for D in $DOMAINS ; do

        echo  "Delete $D"

        ssh $M virsh --connect qemu:///session?socket=/var/run/libvirt/libvirt-sock shutdown $D
        sleep 20
        ssh $M virsh --connect qemu:///session?socket=/var/run/libvirt/libvirt-sock undefine $D --remove-all-storage
    done

done

exit 0


# count app resources

CPU=0; MEM=0 ; for host in $(host -al kube.int | grep 'kvm'|grep -v san|grep -v ilo|grep -v office|awk '{print $1}') ; do echo "$host ---------" ; export mtmp=$(ssh $host -- cat /proc/meminfo | grep MemTotal| awk '{print $2}') ; export mtmp=$(( $mtmp/1024/1024 )) ; MEM=$(( $MEM +  $mtmp )) ;  export ctmp=$(ssh $host -- nproc ) ; CPU=$(( $CPU + $ctmp )) ;echo "NodeMem: $mtmp GB - NodeCPU: $ctmp" ; done ; echo "Total Mem: $MEM GB" ; echo "Total CPU: $CPU"
