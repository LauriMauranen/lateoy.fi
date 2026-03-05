#!/bin/bash

source avustajat.sh

record=false

while getopts "hr" flag; do
    case "${flag}" in
        h) echo "Käyttö: lisaa-domain-loki [asetukset] kayttaja domain" 
	   echo
	   echo "Lisää käyttäjän domainille lokitus-kansion."
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   exit 0
		;;
	r) record=true
		;;
    esac
done

kayttaja="${@:$OPTIND:1}"
domain="${@:$OPTIND+1:1}"

log="$LOKIT/$domain"

# vain käyttäjä näkee sisällön
mkdir -v -m 700 "$log"

chown "$kayttaja" "$log" -R
