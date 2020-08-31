#!/bin/bash
HOSTS=$(cat ansible/inventory/hosts |grep k8s-cluster)
for MACHINENAME in ${HOSTS} ; do



   ./sudo-code.sh  ${MACHINENAME}

done
