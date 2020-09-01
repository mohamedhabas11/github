#Libvirt pools

Create/activate and autostart storage volumes used by libvirt.

#Variables

	libvirt_directory_pools:
	- name: mypool
	  path: /srv/pool


	libvirt_gluster_pools:
	- name: my_shared_pool
	  path: /srv/pool/gluster
	  gluster_host: localhost
	  gluster_volume: gv0
	  
	  
	  
#TODO

For the moment only pools of type "dir" and "netfs/gluster"  are supported.