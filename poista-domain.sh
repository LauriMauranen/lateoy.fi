#!/bin/bash

set -euo pipefail

domains_komento() {
    podman compose run --rm -e LINODE_CLI_TOKEN=$cli_token linode-cli domains \
	--text "$@"
}

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

domain="$1"

data=/www-data/
log="/var/log/$domain"

recordit=
[[ -d "$log" ]] && recordit=$(ls "$log")

rm -rf "$log"

cli_token=$(cat /home/lauri/.secrets/linode/cli.token)

domain_id=$(domains_komento ls | grep "\s$domain\s" || :)

if [[ $domain_id =~ [0-9]+ ]]; then
    domain_id="${BASH_REMATCH[0]}"
else
    echo "Domainin hakeminen Linodelta epäonnistui"
    exit 1
fi

for record in "$recordit"; do
    if [[ "$domain" == "$record" ]]; then
	poista-a-record "$domain" "$record"
    else
	poista-a-record "$domain" "${record%%.*}"
    fi
done

domains_komento rm "$domain_id"

podman exec nginx nginx -s reload
