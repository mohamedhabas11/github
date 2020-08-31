# github
Skeleton Ansible work enviorment that will supervise a Virtual k8s cluster 

# To initiate the setup clone this ripo and start the Installer script

To start with making the KVM-HOST Part on an existing Infrastructure 

obtain set off ssh Keys for KVM_HOST to allow communication between ansible and the KVM-Host & ${"GUEST_MACHINE"}

Once ansible can reach the hosts We can start with our added setup

	./install.sh

###################################################################################################################################
This will start up a Set of guests on the KVM-HOST
####################################################################################################################################

The repo Has predefined ansible play-books to maintaine and setup KVM-HOST .

We will use a Virtual-bridge to give the guests initial connectivity and bootsrab VMS based on ROM the script will use and Ubuntu mirror to download initial .

	./sudo-code.sh
 
#####################################################################################################################################
Important : the script is aware of the posibility these machines do not exist and are to be unique later .
######################################################################################################################################

The script assumes that the desired guests of nodes to live at least a DNS server.

######################################################################################################################################
Important : please maintan the ~/ansible/hosts accordingly 
######################################################################################################################################

clone the ansible repo to be able to start the fist setup on the KVM-HOST

after some ansible magic :) we will have a ready KVM_HOST for our guests and reachable by ansible to add new hosts on .

	ansible-playbook ../../plays/kvm-host.yml --diff

######################################################################################################################################
	
this leads us to the setup of the guests.
	The script wil generate VM's that are have a pre-configered Preseed.cfg :

	1- the location of the Preseed.cfg file is withen the repo if you wanna have a look :) :
		a- the Master template machine that will be created as an only source of dependancy will have the following : 
			 - a sudo User created and added to the SUDO group on the Master template 
			 - an INTERFACE template to able to download the initial OS-version 
			 - openserver-ssh will be running after the boot-up process 
			 - reach-able by ansible-master node 
		b- after the initial install the master template will be stopped and on the KVM-HOST :
			 - on the host we will kill the machine and use its image 
			 - inject different ssh-key pairs for ansible to use 
			 - add static-ip's to the machines that will be created with the start of the soft-clone of the Turned-off nachine 
			 - alocate resourses and the machines will be created in parrallel 
			 - The machines will appear with the same ( Hostname ) as withen the Master-ansible nodes /Inventory/hosts file
			 - Networking according to the porpuse designed in the existing DNS_NAMESERVER 
		c- Withen ansible we can apply different play-books to Update , Install nessecary Software on virtual defined HDD and a Virtual Bridge for Network Access.
			- a dhcp interface card that will be part of a Group name to apply some Network rules withen anible-groups 
			- requirment.txt file has a list of necessary sofware you need ansible to install and configure to the porpuse of this repo .


There is Alot of Bash scripts within the Repo.							 Hello Sys-Admin :)

######################################################################################################################################
scripts/

has an auto install script that takes care of setting up the whole processes for the first time and clone a new repo for you and using this \
	 repository as a skeleton for an infrastructure .
	- ansible is setup with /roles that maintain the KVM-HOST
	- guest-machines are totally erase-able at command 
	- New-host new-repo re-setup test-inviorment friendly . 
												Devops <== Bad advertisement
This repo will bounce of two Maintaned repos
	mohamedhabas.11@github.com/ansible:
	mohamedhabas.11@github.com/kuberntes 							#Missing
	^
	still figuring out kube-adm scripts out 

#####################################################################################################################################
        mohamedhabas.11@github.com/ansible:

Ansible :
	the repository is mainly a to serve as a skeleton for infrastructure as code {IAS} project .
	depencies :
	A- ssh-Keys for the repo to use to access the machines
	B- KVM-Host Must have enough resources to handle the guests machine 
	C- ansible relays on the DNS-server to be updated with the entries of the guest machines 
	D- there is no requirment.txt for the Ansible setup . 	<	 #feel free to Help on auto install ansible on a clean machine .
######################################################################################################################################
Note: I will guide this repo to be a kubernetes testing enviorment and aware of existing setups
######################################################################################################################################

