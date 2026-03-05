#!/bin/bash

source avustajat.sh

poista_linodesta=true

while getopts "hk" flag; do
    case "${flag}" in
        h) echo "Käyttö: poista-a-record [asetukset] a-record domain" 
	   echo
	   echo "Poistaa a-recordin kansiot ja tiedostot."
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

data="/www-data/$koko_domain"
log="$LOKIT/$domain/$koko_domain"

nginx_conf="/home/lauri/nginx/conf.d/$koko_domain.conf"
[[ ! -e "$nginx_conf" ]] && nginx_conf="$nginx_conf.error"

if [[ -e "$nginx_conf" ]]; then
    portti="$(grep "proxy_pass http://$record:\d\d\d\d;" "$nginx_conf" || :)"
    portti="${portti##*:}"
    portti="${portti%;}"

    if [[ -z "$portti" ]]; then
	echo "Portin etsiminen tiedostosta $nginx_conf epäonnistui!" >&2
    else 
	echo "$portti" >> "$PORTIT"
    fi
fi

rm -rfv "$data"
rm -rfv "$log"
rm -rfv "$nginx_conf"
