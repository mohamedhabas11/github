#Libvirt volumes

Ensures that all volumes needed by KVM machines exist.

#Variables


	libvirt_disks:
	- bus: virtio
	  device: vdb
	  disk_name: mysql.test.05.amana.vpn
	  disk_pool: local-pool
	  disk_size: 350G,
	  filesystem: ext4
	  format: qcow2
	  mountpoint: /var/lib/mysql
	  partition_scheme: atomic



#Backing file

	disk_backing_file: [path to backup file]
	
THIS WORKS ONLY WITH qcow2 IMAGES!!!
