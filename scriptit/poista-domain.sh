#!/bin/bash

source avustajat.sh

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

log="/var/log/$domain"

recordit=
[[ -d "$log" ]] && recordit=$(ls -A "$log")

rm -rf "$log"

domain_id=$(hae_domain_id_linodesta "$domain")

for record in "$recordit"; do
    if [[ "$domain" == "$record" ]]; then
	poista-a-record.sh "$domain" "$record"
    elif [[ ! -z "$record" ]]; then
	poista-a-record.sh "$domain" "${record%%.*}"
    fi
done

domains_komento rm "$domain_id"
echo "Domain $domain poistettiin Linodesta"

# podman exec nginx nginx -s reload
