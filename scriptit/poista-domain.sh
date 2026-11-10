#!/bin/bash

source avustajat.sh

while getopts "h" flag; do
    case "${flag}" in
        h) alkuotsikko "kayttaja domain" 
	   echo
	   echo "Poistaa domainin ja sen recordien kansiot paitsi www-data -kansiosta!."
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   exit 0
		;;
    esac
done

if ! tarkista_root; then exit 1; fi

kayttaja="$1"
domain="$2"

for record in $LOKIT/*$domain; do
    record="${record##*/}"
    if [[ "$domain" == "$record" ]]; then
	poista-a-record.sh "$kayttaja" "$record" "$domain" 
    elif [[ ! -z "$record" ]]; then
	poista-a-record.sh "$kayttaja" "${record%%.*}" "$domain" 
    fi
done
