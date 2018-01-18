# nm-opennic

**OpenNIC auto dns updater using Network Manager**

syntax:

./opennic.sh [*userid*] [*userkey*]

Replaces the Network Manager's dns servers with the 3 most responsive OpenNIC dns servers for your location. _resolv.conf_ is also updated for immediate implementation of the new dns entries.

*userid* and *userkey* are optional, they correspond to the member's *user* and *auth* and are used to register one's IP for whitelisting.
