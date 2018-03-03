# opennic-up

**OpenNIC auto DNS updater for Network Manager**

## Installation

The `opennic-up` Bash script can be downloaded to your preferred location.

For a full integration of the automated update process with you system, an **Arch Linux** package is available [here][1].
To enable and start the systemd timer that will update the DNS twice a week, use:
```
# systemctl enable --now opennic-up.timer
```
### Dependencies
The tools *awk*, *sort*, *uniq*, *curl*, *fping*, *xargs*, *drill* and *nmcli* are required and must be found in the environment path.
For Arch Linux users this corresponds to three additional packages on top of the base distribution which will be installed with the package if not already present (*fping*, *curl* and  *networkmanager*).

## Syntax

`# opennic-up`

Replaces the Network Manager's DNS servers with the 3 most responsive [OpenNIC][0] DNS servers for your location. `resolv.conf` is also updated for immediate implementation of the new DNS entries.

## Configuration

`opennic-up.conf` is the config file for *opennic-up*. 

*opennic-up* looks for the file at the location `/etc/opennic-up.conf`. Alternatively it can be saved in the user location `~/.config/opennic-up/opennic-up.conf` and in this case it takes precedence over the former.

The file defines the OpenNIC [member][3]'s **user** and **auth** used to register one's IP for [whitelisting][4]. For example:
```
user=myusername
auth=TbuARbBxHHGznNScvVLKZDDR9ZGVKdhqxj8dkzCQ
```

[0]: https://www.opennicproject.org/
[1]: https://aur.archlinux.org/packages/opennic-up
[3]: https://www.opennicproject.org/members/
[4]: https://wiki.opennic.org/api/whitelist