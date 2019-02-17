# opennic-up

**OpenNIC auto DNS updater**

## Installation
### Manual installation
The `opennic-up` Bash script can be downloaded to your preferred location.
The systemd service and timer provided are to be copied to `/usr/lib/systemd/system/`.

### Arch linux package
For a full integration of the automated update process, an **Arch Linux** package is available [here][1].

### Scheduled update with systemd time
A systemd timer unit is provided, to enable and start the timer that will update the DNS servers twice a week, use:
```
# systemctl enable --now opennic-up.timer
```
### Dependencies
The tools *awk*, *sort*, *uniq*, *curl*, *fping*, *xargs*, *drill* are required and must be found in the environment path.
For Arch Linux users this corresponds to two additional packages on top of the base distribution which will be installed with the package if not already present: *fping* and *curl*.

## Syntax

`# opennic-up [options]`
```
options:
    -q  quiet
    -v  version
    -h  help
```

By default, replaces the DNS servers with the 3 most responsive [OpenNIC][0] DNS servers for your location.

* If Network Manager *nmcli* is found in the path, it is used to update the DNS entries
* Otherwise the `/etc/resolv.conf` file is updated directly with the new nameservers keeping the other options untouched

## Configuration

`opennic-up.conf` is the configuration file for *opennic-up*. 

*opennic-up* looks for the file at the location `/etc/opennic-up.conf`. Alternatively it can be saved in the user location `~/.config/opennic-up/opennic-up.conf` and in this case it takes precedence over the former.

The configuration file defines the OpenNIC [member][3]'s **user** and **auth** used to register one's IP for [whitelisting][4]. For example:
```
user=myusername
auth=TbuARbBxHHGznNScvVLKZDDR9ZGVKdhqxj8dkzCQ
```
The number of DNS servers to retain, 3 by default, can be changed using the **maxretain** option:
```
maxretain=2
```


[0]: https://www.opennicproject.org/
[1]: https://aur.archlinux.org/packages/opennic-up
[3]: https://www.opennicproject.org/members/
[4]: https://wiki.opennic.org/api/whitelist