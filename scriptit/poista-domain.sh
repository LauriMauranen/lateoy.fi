#!/bin/bash

set -euo pipefail

source avustajat.sh

while getopts "h" flag; do
    case "${flag}" in
        h) echo "Käyttö: poista-domain domain" 
	   echo
	   echo "Poistaa domainin ja sen recordien kansiot paitsi www-data -kansiosta!."
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   exit 0
		;;
    esac
done

domain="$1"

log="$LOKIT/$domain"

recordit=
[[ -d "$log" ]] && recordit=$(ls -A1 "$log")

rm -rf "$log"

for record in $recordit; do
    if [[ "$domain" == "$record" ]]; then
	poista-a-record.sh "$record" "$domain" 
    elif [[ ! -z "$record" ]]; then
	poista-a-record.sh "${record%%.*}" "$domain" 
    fi
done
