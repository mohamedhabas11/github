#LVM

##Description

Manage thin and normal volumes.

##Variables

*** Important ***
Thin LV is created if 'poolname' value is defined in an item in lvm2_volumes or lvm2_volumes_extra dicts:

	lvm2_volumes_extra:
	- fstype: ext4
	  mountpoint: /srv/backup
	  name: backup
	  poolname: lv_thin_pool                              <----------
	  size: 3.5T
	  volumegroup: vg_thin

 If 'poolname' key is missing, normal LV is created instead.
