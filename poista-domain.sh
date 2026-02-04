#!/bin/bash

set -euo pipefail

while getopts "h" flag; do
    case "${flag}" in
        h) echo "Käyttö: poista-domain domain" 
	   echo
	   echo "Poistaa domainin ja sen a-recordit"
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   exit 0
		;;
    esac
done

data=/www-data/
log="/var/log/$domain"

recordit=
[[ -d "$log" ]] && recordit=$(ls "$log")

rm -rf "$log"

cli_token=$(cat /home/lauri/.secrets/linode/cli.token)
domain_id=$(podman compose run --rm -e LINODE_CLI_TOKEN="$cli_token" linode-cli \
    --text domains ls | grep "\s$domain\s" || :)

if [[ $domain_id =~ [0-9]+ ]]; then
    domain_id="${BASH_REMATCH[0]}"
else
    echo "Domainin hakeminen Linodelta epäonnistui"
    exit 1
fi

for record in "$recordit"; do
    poista-a-record "$domain_id" "$domain" "$record"
done

podman compose run --rm -e LINODE_CLI_TOKEN=$cli_token linode-cli \
    domains rm "$domain_id"

podman exec nginx nginx -s reload
