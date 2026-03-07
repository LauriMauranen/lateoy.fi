#!/bin/bash

source avustajat.sh

while getopts "h" flag; do
    case "${flag}" in
        h) echo "Käyttö: lisaa-domain-loki [asetukset] kayttaja domain" 
	   echo
	   echo "Lisää käyttäjän domainille lokitus-kansion."
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   exit 0
		;;
    esac
done

kayttaja="${@:$OPTIND:1}"
domain="${@:$OPTIND+1:1}"

if [[ -z "$kayttaja" || -z "$domain" ]]; then
    echo "'kayttaja' ja 'domain' ovat pakollisia!"
    exit 1 
fi

log="$LOKIT/$domain"

mkdir -v -m 760 "$log"
chown "lauri:$kayttaja" "$log" -R
