#!/bin/bash

testiajo=false
[[ "$TESTIAJO" == true ]] && testiajo=true

source avustajat.sh

record=false

while getopts "hr" flag; do
    case "${flag}" in
        h) echo "Käyttö: lisaa-domain [asetukset] kayttaja domain" 
	   echo
	   echo "Lisää käyttäjälle domainin Linodeen ja lokitus-kansion."
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   echo "  -r            Luo domainille myös A record."	
	   exit 0
		;;
	r) record=true
		;;
    esac
done

kayttaja="${@:$OPTIND:1}"
domain="${@:$OPTIND+1:1}"

log="/var/log/sovelluslokit/$domain"

mkdir -v -m 700 "$log"

if ! "$testiajo"; then
    chown "$kayttaja" "$log" -R
fi

email=lauri.mauranen@gmail.com
domains_komento create --domain "$domain" --type master --soa_email "$email"

if "$record"; then lisaa-a-record.sh $kayttaja $domain $domain; fi
