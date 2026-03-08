#!/bin/bash

source avustajat.sh

if ! tarkista_root; then exit 1; fi

while getopts "h" flag; do
    case "${flag}" in
        h) echo "Käyttö: poista-domain.sh domain" 
	   echo
	   echo "Poistaa domainin ja sen recordien kansiot paitsi www-data -kansiosta!."
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   exit 0
		;;
    esac
done

domain="$1"

# recordit=$(ls -A1 "$log")
for record in $LOKIT/*$domain; do
    record="${record##*/}"
    if [[ "$domain" == "$record" ]]; then
	poista-a-record.sh "$record" "$domain" 
    elif [[ ! -z "$record" ]]; then
	poista-a-record.sh "${record%%.*}" "$domain" 
    fi
done
