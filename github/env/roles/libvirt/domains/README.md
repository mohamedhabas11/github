#Libvirt domains

#Network

To use old eth names add this:

    vi_grub_cmd_line: "net.ifnames=0 biosdevname=0"
    
Multiple network cards:
    
    vi_networks: 
    - bridge=br2201,model=virtio
    - bridge=br1072,model=virtio

#Variables


    vi_autostart: True
    vi_memory: 8G
    vi_network: bridge=br2,model=e1000
    vi_num_cpu: 1
    vi_os_type: linux
    vi_os_variant: ubuntu16.04
    vi_virt_type: kvm

##Optional

Don't know if this is usable for windoes.
For linux you can add bootparams here:

    vi_extra_args: locale=de_CH.UTF-8 console-setup/ask_detect=false keyboard-configuration/layoutcode=ch file=file:/preseed.cfg vga=788 quiet

##Boot options

###Install Linux via HTTP

    vi_location: http://de.archive.ubuntu.com/ubuntu/dists/xenial-updates/main/installer-amd64/

the you need to define preseeding template to use

    vi_preseed_template: preesed-xenial.cfg.j2
    vi_preseed_template: preesed-bionic.cfg.j2

###Add boot method

    vi_boot_from: hd


#Example to accept all new keys from a group of servers (mysql)

	for env in stage prod test ; do
		for num in 03 04 05 ; do
			echo mysql.$env.$num.amana.vpn
			ssh -oStrictHostKeyChecking=no mysql.$env.$num.amana.vpn -l ansible -i storage/ansible-keys/mysql.$env.$num.amana.vpn  exit
		done
	done

#Do base provisioning with group of servers (mysql)

	for env in stage prod test ; do
		for num in 03 04 05 ; do
			echo mysql.$env.$num.amana.vpn
				export FQDN=mysql.$env.$num.amana.vpn
				ansible-playbook ../../plays/setup/hostnames.yml --limit=${FQDN}
				ansible-playbook ../../plays/setup/resolvconf.yml --limit=${FQDN}
				ansible-playbook ../../plays/setup/sysadmins.yml --limit=${FQDN}
				ansible-playbook ../../plays/setup/rsyslog.yml --limit=${FQDN}
				ansible-playbook ../../plays/setup/fetch-pubkeys.yml --limit=${FQDN}
				ansible-playbook ../../plays/setup/timezone.yml --limit=${FQDN}
				ansible-playbook ../../plays/setup/bashrc.yml --limit=${FQDN}
				ansible-playbook ../../plays/setup/root-ca.yml --limit=${FQDN}
		 		ansible-playbook ../../plays/setup/zabbix-env.yml --limit=${FQDN}
		done
	done

#Faster machine creation

Pass this variable to play:

	libvirt_guests_background_creation: true

creation process is put in background

# Misc
- pwgen must be installed on local machine
- For osx: brew install pwgen
