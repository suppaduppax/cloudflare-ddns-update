#!/bin/bash

# Script adapted from:
# https://gist.github.com/Tras2/cba88201b17d765ec065ccbedfb16d9a#file-cloudflare-ddns-update-sh

# A bash script to update a Cloudflare DNS A record with the external IP of the source machine
# Used to provide DDNS service for my home
# Needs the DNS record pre-created on Cloudflare
# Requires cloudflare user email.
# Uses authentication token.


# Proxy - uncomment and provide details if using a proxy
#export https_proxy=http://<proxyuser>:<proxypassword>@<proxyip>:<proxyport>

# Discord notification settings
# Set discord_notif_enabled to false to disable discord notifications
discord_notif_enabled=true
discord_webhook=https://discord.com/api/webhooks/INSERT_WEBHOOK_HERE

# Cloudflare zone is the zone which holds the record
zone=example.com

# dnsrecord is the A record which will be updated
dnsrecord=www.example.com

# website to check internal ip
internal_ip_site='https://checkip.amazonaws.com'

## Cloudflare authentication details
## keep these private
cloudflare_auth_email=me@cloudflare.com
cloudflare_auth_token=1234567890abcdef1234567890abcdef



### Do not edit below this line #############

# sends discord message using webhook
# params: $1 = discord message
function discord_notif () {
  curl -sS \
    -H "Content-Type: application/json" \
    -d "{\"username\": \"$discord_username\", \"content\": \"$1\"}" \
    $discord_webhook

  echo "$1"
}

# Get the current external IP address
ip=$(curl -sS -X GET "$internal_ip_site")

echo "Current IP is $ip"

dnsip=$(host $dnsrecord 1.1.1.1 | grep 'has address' | grep -oe '[0-9.]*$' )

if host $dnsrecord 1.1.1.1 | grep "has address" | grep "$ip"; then
  echo "$dnsrecord is currently set to $ip; no changes needed"
  exit 0
fi

# if here, the dns record needs updating

# get the zone id for the requested zone
zoneid=$(curl -sS -X GET "https://api.cloudflare.com/client/v4/zones?name=$zone&status=active" \
  -H "X-Auth-Email: $cloudflare_auth_email" \
  -H "Authorization: Bearer $cloudflare_auth_token" \
  -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

echo "Zoneid for $zone is $zoneid"

# get the dns record id
dnsrecordid=$(curl -sS -X GET "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records?type=A&name=$dnsrecord" \
  -H "X-Auth-Email: $cloudflare_auth_email" \
  -H "Authorization: Bearer $cloudflare_auth_token" \
  -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

echo "DNSrecordid for $dnsrecord is $dnsrecordid"

# update the record
updateresult=$(curl -sS -X PUT "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records/$dnsrecordid" \
  -H "X-Auth-Email: $cloudflare_auth_email" \
  -H "Authorization: Bearer $cloudflare_auth_token" \
  -H "Content-Type: application/json" \
  --data "{\"type\":\"A\",\"name\":\"$dnsrecord\",\"content\":\"$ip\",\"ttl\":1,\"proxied\":false}" | jq -r '.result | .content')

# send discord notification
if [ "$discord_notif_enabled" = true ]; then
  discord_notif "Updated $dnsrecord record from \`$dnsip\` to \`$updateresult\`"
fi
