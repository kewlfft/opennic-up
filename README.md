# opennic-up

**OpenNIC auto dns updater using Network Manager**

## Syntax

`# opennic-up`

Replaces the Network Manager's dns servers with the 3 most responsive OpenNIC dns servers for your location. `resolv.conf` is also updated for immediate implementation of the new dns entries.

## Configuration

`opennic-up.conf` is the config file for opennic-up. 

opennic-up looks for the file at the location `/etc/opennic-up.conf`, alternatively it can be saved at the location `~/.config/opennic-up/opennic-up.conf`
The file contains two lines defining *user* and *auth* for the member and are used to register one's IP for whitelisting. For example:
```
user=myusername
auth=TbuARbBxHHGznNScvVLKZDDR9ZGVKdhqxj8dkzCQ
```