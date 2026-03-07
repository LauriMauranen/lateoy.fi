#!/bin/bash

source avustajat.sh

poista_linodesta=true

while getopts "hk" flag; do
    case "${flag}" in
        h) echo "Käyttö: poista-a-record [asetukset] a-record domain" 
	   echo
	   echo "Poistaa a-recordin lokit ja nginx-konfiguraation. Ei koske www-data -kansioon!"
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   exit 0
		;;
	k) poista_linodesta=false
		;;
    esac
done

record="${@:$OPTIND:1}"
domain="${@:$OPTIND+1:1}"

koko_domain=$(tee_koko_domain "$domain" "$record")

log="$LOKIT/$domain/$koko_domain"

nginx_conf="$NGINX_CONFD/$koko_domain.conf"
[[ ! -e "$nginx_conf" ]] && nginx_conf="$nginx_conf.error"

if [[ -e "$nginx_conf" ]]; then
    laita_portti_takaisin "$nginx_conf" "$koko_domain" >> "$PORTIT"
fi

rm -rfv "$log"
rm -rfv "$nginx_conf"
