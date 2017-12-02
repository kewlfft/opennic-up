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
	echo "$needed_single (a necessary tool used by this script) is not installed on this computer or has not been found in your environment paths ($PATH)" 1>&2
	exit 1
done

# find out what the IP address of api.opennicproject.org is
apihost=$(dnslookup)
if [ "x$apihost" == "x" ]; then
  # our fallback is to have a static IP address configured of api.opennicproject.org
  echo "API IP not found, using default"
  apihost="161.97.219.82"
fi
echo "Using $apihost as API host" 1>&2

# record my IP in whitelist if my account parameters have been passed: userid and keyid
if [ $# -eq 2 ]; then
    curl --resolve "api.opennicproject.org:443:$apihost" "https://api.opennicproject.org/ip/update/?user=$1&auth=$2"
fi

# query the API for 200 sites
apiurl="https://api.opennicproject.org/geoip/?list&ipv=4&res=200&adm=0&bl&wl"
echo $apiurl
hosts=$(curl --silent --resolve "api.opennicproject.org:443:$apihost" $apiurl)

# filter hosts with more than 90% reliability
myhosts=$(echo "$hosts" | awk -F# '$3 + 0.0 > 90' | awk -F# '{print $1}')
myhostscount=$(echo "$myhosts" | wc -l)

if [ "$myhostscount" -ge 2 ]; then

  #pinging the hosts
  echo "Pinging $myhostscount hosts to determine the top ones..." 1>&2
  pingresults=$(multiping $myhosts)

  # We throw away servers that fall below the average packet loss of all servers
  # Illustration of packet loss filter:
  # 5 servers: #1 received 1 response, #2 received 2 responses, #3 received 3 responses, #4 = 4, #5 = 5
  # (1+2+3+4+5)/5 = 3, the average amount of responses per server is 3
  # we filter out all servers that have a response packet count of below 3 (in this case #1 and #2 fall out of our list; #3, #4 and #5 are the servers we're going to test)
  avgrcvd=$(echo "$pingresults" | awk -F/ 'BEGIN{sum=0;count=0;}{count+=1;sum+=$4}END{print sum/count;}')

  # Here we will finally apply the packet loss filter and also sort the servers by their average response time
  hosts=$(echo "$pingresults" | awk -F/ '$4 >= '$avgrcvd'' | sort -t/ -nk8)
  hostscount=$(echo "$hosts" | wc -l)
  echo "Resulting in $hostscount responsive hosts"

  # we retain the top 3 servers for our DNS and keep only the IP column
  hostsshortlist=$(echo "$hosts" | head -n 3 | awk '{print $1}')
  echo "$hostsshortlist"

  # replace Network Manager DNS with the new ones for all active connections
  if [ "$hostscount" -ge 2 ]; then
    for id in $(nmcli -terse -fields UUID connection show --active)
    do
      currentdnss=$(nmcli -terse -fields ipv4.dns connection show $id | cut -d: -f2- | tr "," "\n")
      if [ "$(echo "$currentdnss" | sort)" == "$(echo "$hostsshortlist" | sort)" ]
      then
          echo "No dns change"
      else
          #statements
          for dns in $currentdnss
          do
            nmcli connection modify $id -ipv4.dns $dns
          done

          for dns in $hostsshortlist
          do
            nmcli connection modify $id +ipv4.dns $dns
          done
          echo "Updating $id"
          nmcli connection up $id
      fi
    done
  else
    echo "Not enough responsive OpenNIC servers available"
  fi

else
  echo "Not enough OpenNIC servers available"
fi
