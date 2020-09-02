#!/bin/bash

cd "$(dirname $0)"

source env.sh

if [ ! -f ${BASE_TEMPLATE} ] ; then


    # create base image
    qemu-img create ${BASE_TEMPLATE} 350G -f qcow2
    
    virt-install --name k8s-base-template --ram 2048 \
        --disk path=${BASE_TEMPLATE},bus=virtio \
        --boot hd,cdrom \
        --graphics vnc \
        --vcpus 2 --virt-type kvm  --os-type linux --os-variant ubuntu18.04 \
        --location='http://ch.archive.ubuntu.com/ubuntu/dists/bionic/main/installer-amd64/' \
        --initrd-inject=/home/ansible/templates/preseed.cfg \
        --extra-args="net.ifnames=0 biosdevname=0 netcfg/do_not_use_netplan=true ipv6.disable=1 console-setup/ask_detect=false file=file:/preseed.cfg vga=788 quiet" \
        --wait 10

fi

# ensure base machine is off, but keep image
virsh destroy k8s-base-template 2>/dev/null
virsh undefine k8s-base-template 2>/dev/null


# create base overlay for each domain
for DOMAIN in ${HOSTS} ; do 
    echo "Create overlay for ${DOMAIN}"

    qemu-img create -q "${BASE_IMAGES_DIR}/${DOMAIN}-base.qcow2" -f qcow2 -b ${BASE_TEMPLATE}
done


# pre-configure
for DOMAIN in ${HOSTS} ; do

    IP=$(host ${DOMAIN}.K8s-infra | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
    export IP
    mkdir -p "/tmp/${DOMAIN}/etc/network" 2>/dev/null

    echo "Configure network for ${DOMAIN}"
    cat /home/ansible/templates/interfaces | envsubst > "/tmp/${DOMAIN}/etc/network/interfaces"
    echo ${DOMAIN} > "/tmp/${DOMAIN}/etc/hostname"
    cat /home/ansible/templates/resolv.conf > "/tmp/${DOMAIN}/etc/resolv.conf"

    virt-copy-in -a "${BASE_IMAGES_DIR}/${DOMAIN}-base.qcow2" "/tmp/${DOMAIN}/etc/network/interfaces" /etc/network
    virt-copy-in -a "${BASE_IMAGES_DIR}/${DOMAIN}-base.qcow2" "/tmp/${DOMAIN}/etc/hostname" /etc
    virt-copy-in -a "${BASE_IMAGES_DIR}/${DOMAIN}-base.qcow2" "/tmp/${DOMAIN}/etc/resolv.conf" /etc

done

# ensure all templates have proper perms
chown -R libvirt-qemu:kvm /srv/libvirt/pool
