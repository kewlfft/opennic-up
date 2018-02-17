# opennic-up

**OpenNIC auto DNS updater for Network Manager**

## Syntax

`# opennic-up`

Replaces the Network Manager's DNS servers with the 3 most responsive [OpenNIC][0] DNS servers for your location. `resolv.conf` is also updated for immediate implementation of the new DNS entries.

## Configuration

`opennic-up.conf` is the config file for *opennic-up*. 

*opennic-up* looks for the file at the location `/etc/opennic-up.conf`, alternatively it can be saved at the location `~/.config/opennic-up/opennic-up.conf`.

The file contains two lines defining the OpenNIC [member][3]'s **user** and **auth** used to register one's IP for [whitelisting][4]. For example:
```
user=myusername
auth=TbuARbBxHHGznNScvVLKZDDR9ZGVKdhqxj8dkzCQ
```

## Arch Linux package

It is available [here][1].

[0]: https://www.opennicproject.org/
[1]: https://aur.archlinux.org/packages/opennic-up
[3]: https://www.opennicproject.org/members/
[4]: https://wiki.opennic.org/api/whitelist