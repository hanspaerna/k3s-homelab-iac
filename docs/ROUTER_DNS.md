k3s-int requires truenas.lan to be reachable.
	
	Some clients (like TV) cannot access Netbird network easily. Others need to remain accessible even if there is no connection to the internet.
	This is why we also want to resolve certain hosts on the local network level.
	
	```
	192.168.8.xxx truenas.lan
	192.168.8.xxx pve.lan
	192.168.8.xxx jellyfin.vpn.fingol.pro
	```
	
	The easiest way is to put it into router's DNS.
