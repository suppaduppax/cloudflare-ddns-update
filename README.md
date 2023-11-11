# cloudflare-ddns-update

> **Script adapted from:** \
> https://gist.github.com/Tras2/cba88201b17d765ec065ccbedfb16d9a#file-cloudflare-ddns-update-sh

A bash script to update a Cloudflare DNS A record with the external IP of the source machine
Used to provide DDNS service for my home
Needs the DNS record pre-created on Cloudflare
Requires cloudflare user email.
Uses authentication token.


Proxy - uncomment and provide details if using a proxy \
```bash
#export https_proxy=http://<proxyuser>:<proxypassword>@<proxyip>:<proxyport>
```

# Discord notification settings
Set discord_notif_enabled to false to disable discord notifications
```bash
discord_notif_enabled=true
discord_webhook=https://discord.com/api/webhooks/INSERT_WEBHOOK_HERE
```
# Cloudflare zone is the zone which holds the record
```bash
zone=example.com
```

# dnsrecord is the A record which will be updated
```
dnsrecord=www.example.com
```

# website to check internal ip
```bash
internal_ip_site='https://checkip.amazonaws.com'
```

# Cloudflare authentication details
```bash
cloudflare_auth_email=me@cloudflare.com
cloudflare_auth_token=1234567890abcdef1234567890abcdef
```
