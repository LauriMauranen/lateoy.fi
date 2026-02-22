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
[[ -d "$log" ]] && recordit=$(ls -A1 "$log")

rm -rf "$log"

for record in $recordit; do
    if [[ "$domain" == "$record" ]]; then
	poista-a-record.sh -k "$record" "$domain" 
    elif [[ ! -z "$record" ]]; then
	poista-a-record.sh -k "${record%%.*}" "$domain" 
    fi
done

poista_domain_linodesta "$domain"

# podman exec nginx nginx -s reload
