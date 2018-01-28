#!/usr/bin/env bash

# pings run in parallel
multiping() {
  fping -q -p 20 -r 0 -c 25 "$@" 2>&1
}

# dns lookup using google 8.8.8.8
dnslookup() {
  drill A api.opennicproject.org @8.8.8.8 | awk '$1 == "api.opennicproject.org." && $3 == "IN" && $4 == "A" {print $5}'
}

# check needed packages are present
needed="awk sort uniq curl fping xargs drill"
for needed_single in $needed; do
	which "$needed_single" > /dev/null 2> /dev/null && continue
	echo "$needed_single: is required, it is not installed or has not been found in your environment paths" 1>&2
	exit 1
done

# wait for internet 20s*4
fping -q -t 20000 8.8.8.8

# find out what the IP address of api.opennicproject.org is, fallback static IP address configured
apihost=$(dnslookup)
apihost=${apihost:-"161.97.219.82"}
echo "Using $apihost as API host"

# record my IP in whitelist if my account login parameters have been passed [userid] and [keyid]
if [ $# -eq 2 ]; then
  curl --connect-timeout 60 --resolve "api.opennicproject.org:443:$apihost" "https://api.opennicproject.org/ip/update/?user=$1&auth=$2"
fi

# query the API for 200 sites
apiurl='https://api.opennicproject.org/geoip/?list&ipv=4&res=200&adm=0&bl&wl'
echo $apiurl
allhosts=$(curl --silent --connect-timeout 60 --resolve "api.opennicproject.org:443:$apihost" $apiurl)

if [ -z "$allhosts" ]; then
  echo 'API not available' 1>&2
  exit 1
fi

# filter hosts with more than 90% reliability
reliable=$(echo "$allhosts" | awk -F# '$3 + 0.0 > 90' | awk -F# '{print $1}')
reliablecount=$(echo "$reliable" | wc -l)

if [ "$reliablecount" -ge 2 ]; then
  #pinging the hosts
  echo "Pinging $reliablecount hosts to determine the top ones..."
  pingresults=$(multiping $reliable)

  # we apply the packet loss filter and also sort the servers by their average response time and keep only the IP column
  responsive=$(echo "$pingresults" | awk -F/ '$5 + 0.0 < 10' | sort -t/ -nk8 | awk '{print $1}')
  responsivecount=$(echo "$responsive" | wc -l)
  echo "Resulting in $responsivecount responsive hosts"

  # replace Network Manager DNS with the new ones for all active connections
  if [ "$responsivecount" -ge 2 ]; then
    # we retain the top 3 servers for our DNS
    myhosts=$(echo "$responsive" | head -n 3)
    for dns in $myhosts; do
      echo "$allhosts" | grep $dns
    done

    for id in $(nmcli -terse -fields UUID connection show --active); do
      currentdnss=$(nmcli -terse -fields ipv4.dns connection show $id | cut -d: -f2- | tr "," "\n")
      if [ "$(echo "$currentdnss" | sort)" == "$(echo "$myhosts" | sort)" ]; then
          echo 'No dns change'
      else
          #statements
          for dns in $currentdnss; do
            nmcli connection modify $id -ipv4.dns $dns
          done

          for dns in $myhosts; do
            nmcli connection modify $id +ipv4.dns $dns
          done
          echo "Updating $id"
          nmcli connection up $id
      fi
    done
  else
    echo 'Not enough responsive OpenNIC servers available' 1>&2
  fi

else
  echo 'Not enough OpenNIC servers available' 1>&2
fi
