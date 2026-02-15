#!/bin/bash

source avustajat.sh

record=false

while getopts "hr" flag; do
    case "${flag}" in
        h) echo "Käyttö: lisaa-domain kayttaja domain" 
	   echo
	   echo "Lisää käyttäjälle domainin Linodeen ja lokitus-kansion."
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   echo "  -r            Luo domainille myös A/AAAA record."	
	   exit 0
		;;
	r) record=true
		;;
    esac
done

kayttaja="$1"
domain="$2"

log="/var/log/$domain"

mkdir -v "$log"
chown "$kayttaja" "$log" -R

email=lauri.mauranen@gmail.com

domains_komento create --domain $domain --type master --soa_email $email

if "$record"; then lisaa-a-record $kayttaja $domain $domain; fi
