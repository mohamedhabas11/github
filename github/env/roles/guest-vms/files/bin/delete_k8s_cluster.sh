#!/bin/bash

HOSTS=$(host -al K8s-infra | awk '{print $1}' | sed -e 's/K8s-infra.$//')

for HOST in ${HOSTS} ; do

    virsh destroy ${HOST}

done


for HOST in ${HOSTS} ; do

    virsh undefine --domain ${HOST} --remove-all-storage

done

