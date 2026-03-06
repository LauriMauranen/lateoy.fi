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

log="$LOKIT/$domain"

mkdir -v "$log"
chown "$kayttaja" "$log" -R
