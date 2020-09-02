#!/bin/bash


cd "$(dirname $0)"

source env.sh

# delete old cluster
source delete_k8s_cluster.sh


# start test cluster
for DOMAIN in ${HOSTS} ; do


	# ram
	RAM=2048
	case ${DOMAIN} in
	  worker-office-*) RAM=12288 ;;
	  etcd-office-*) RAM=4096 ;;
	  master-office-*) RAM=8192 ;;
	esac

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





