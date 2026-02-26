#!/bin/bash

source avustajat.sh

poista_linodesta=true

while getopts "hk" flag; do
    case "${flag}" in
        h) echo "Käyttö: poista-a-record [asetukset] a-record domain [domain_id]" 
	   echo
	   echo "Poistaa a-recordin Linodesta ja siihen liittyvät kansiot."
	   echo
	   echo "  -k            Poista vain kansiot. Ei poista recordia Linodesta."
	   echo "  -h            Tulosta tämä viesti."	
	   exit 0
		;;
	k) poista_linodesta=false
		;;
    esac
done

record="${@:$OPTIND:1}"
domain="${@:$OPTIND+1:1}"
domain_id="${@:$OPTIND+2:1}"

if ! ("$poista_linodesta" || [[ -z "$domain_id" ]]); then
    echo "domain_id annettu vaikka ei poisteta recordia Linodesta!"
    exit 1
fi

koko_domain=$(tee_koko_domain "$domain" "$record")

data="/www-data/$koko_domain"
log="/var/log/$domain/$koko_domain"
portit=/home/lauri/nginx/porttinumerot.txt

nginx_conf="/home/lauri/nginx/conf.d/$koko_domain.conf"
[[ ! -e "$nginx_conf" ]] && nginx_conf="$nginx_conf.error"

if [[ -e "$nginx_conf" ]]; then
    portti="$(grep "proxy_pass http://$record:\d\d\d\d;" "$nginx_conf" || :)"
    portti="${portti##*:}"
    portti="${portti%;}"

    if [[ -z "$portti" ]]; then
	echo "Portin etsiminen tiedostosta $nginx_conf epäonnistui!" >&2
    else 
	echo "$portti" >> "$portit"
    fi
fi

rm -rfv "$data"
rm -rfv "$log"
rm -rfv "$nginx_conf"

if "$poista_linodesta"; then
    [[ -z "$domain_id" ]] && domain_id=$(hae_domain_id_linodesta "$domain")
    record_id=$(hae_record_id_linodesta "$record" "$domain" "$domain_id")
    domains_komento records-delete "$domain_id" "$record_id"
fi

[[ "$TESTIAJO" == true ]] && exit 0

podman exec nginx nginx -s reload
