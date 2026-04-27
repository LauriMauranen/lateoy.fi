#!/bin/bash

source avustajat.sh

while getopts "h" flag; do
    case "${flag}" in
        h) echo "Käyttö: poista-a-record.sh [asetukset] a-record domain" 
	   echo
	   echo "Poistaa a-recordin kansiot ja tiedostot."
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   exit 0
		;;
    esac
done

if ! tarkista_root; then exit 1; fi

record="${@:$OPTIND:1}"
domain="${@:$OPTIND+1:1}"

if [[ -z "$record" || -z "$domain" ]]; then
    echo "'a-record' ja 'domain' ovat pakollisia!"
    exit 1 
fi

koko_domain=$(tee_koko_domain "$domain" "$record")

nginx_conf="$NGINX_CONFD/$koko_domain.conf"
[[ ! -e "$nginx_conf" ]] && nginx_conf="$nginx_conf.error"

if [[ -e "$nginx_conf" ]]; then
    portti="$(laita_portti_takaisin "$nginx_conf")"
    echo "$portti" >> "$PORTIT"
    echo "Muista sulkea palomuurista portti $portti"
    echo
fi

rm -rfv "$LOKIT/$koko_domain"
rm -rfv "/www-data/$koko_domain"
rm -rfv "$nginx_conf"

