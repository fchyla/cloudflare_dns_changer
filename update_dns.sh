#!/bin/bash

source ../cloudflare.vars

WAN_IP=`curl ifconfig.co`
CF_RECORD_IP=`curl -sS -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
     -H "X-Auth-Email: $CF_EMAIL" \
     -H "X-Auth-Key: $CF_API_KEY" \
     -H "Content-Type: application/json" | jq -r '.[].content' 2>/dev/null`

if [[ $CF_RECORD_IP != $WAN_IP ]]; then
  logger "Changing VPN DNS record to $WAN_IP"
  #Change IP via cloudflare api
  curl -sS -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
     -H "X-Auth-Email: $CF_EMAIL" \
     -H "X-Auth-Key: $CF_API_KEY" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"'$DNS_RECORD'","content":"'$WAN_IP'","proxied":false}'
  #Notify via pushbullet
  curl -sS --header 'Access-Token: '$PP_API'' \
     --header 'Content-Type: application/json' \
     --data-binary '{"body":"IP changed to '$WAN_IP'","title":"IP changed","type":"note", "email":"'$PP_EMAIL'"}' \
     --request POST \
     https://api.pushbullet.com/v2/pushes
fi
