# Amana networking

Define all interfaces as a list of dicts

# Variables

all interfaces are defined as list in `network_interfaces_map`

## Common variables

Enable /etc/network/interface template debugging by changing default variable to yes:
    network_debugging: no

Required

    name: inerface name

Optional
	
	family: default value: inet
	method: manual or static (default value: manual)
	activate: false, auto or allow-hotplug (default value: auto)
	type: simple, bond, bridge or vlan (default value: simple)
	address: if not defined "inventory_hostname" will be resolved
	gateway: if not defined x.x.x.1 one from address will be used
	netmask: if not defined standard netmask for class a,b or c net will be used (depends on first octet)
	mtu: default 1500
	configlines: list with "freestyle" options to add to interface config
	
This configures amana.vpn default dns and searchdomain

	default_dns: True

## Variables for bonding interfaces

Required

    bond_slaves: a list with the names of slave interfaces to use
  
Optional
	
    bond_mode: default value: 1
    bond_miimon: default value: 100
    bond_downdelay: default value: 200
    bond_updelay: default value: 200

Bonding modes:

	mode=0 (balance-rr)
	mode=1 (active-backup)
	mode=2 (balance-xor)
	mode=3 (broadcast)
	mode=4 (802.3ad)
	mode=5 (balance-tlb)
	mode=6 (balance-alb)
	
## Variables for vlan interfaces

Required

	vlan_raw_device: parent interface name
	
	
## Variables for bridging interfaces

Required

	bridge_ports: a list with the names of interfaces which are connected to this bridge


# Secondary routing table

To make a 2nd interface accessable from outer world:
	
	routingtable: "78"
    iface_gw: 10.190.78.1
    
This will create all ip commands to use this gateway as default when packet arrives on this interface

# Examples

Create simple interface 


	- name: eno1
	  method: static
	  address: 192.168.33.12
	  gateway: 192.168.33.254
	  netmask: 255.255.255.0
	  
  
# IP-Tables start/stop script

	network_iptables: True
	  
	  
