#!/bin/bash

BASE_IMAGES_DIR=/srv/libvirt/pool/base
BASE_TEMPLATE="${BASE_IMAGES_DIR}/k8s-base-template.qcow2"
HOSTS=$(host -al K8s-infra | grep ' $DNS_SERVER_DOMAIN '  | awk '{print $1}' | sed -e 's/K8s-infra$//')

if [ ! -d ${BASE_IMAGES_DIR} ] ; then
	mkdir ${BASE_IMAGES_DIR}
fi
