#!/bin/bash

source avustajat.sh

laita_portti_takaisin() {
    local portit="$1"
    local nginx_conf="$2"
    local record=${nginx_conf##*/}
    local record=${record%.*}

    local portti=$(grep -P "proxy_pass http://$record:\d{4};" $nginx_conf || :)
    local portti=${portti##*:}
    local portti=${portti%;}

    if [[ -z $portti ]]; then
	echo "Portti on tyhjä merkkijono!"
    else 
	echo "$portti" >> $portit
    fi
}

while getopts "h" flag; do
    case "${flag}" in
        h) echo "Käyttö: poista-a-record domain a-record" 
	   echo
	   echo "Poistaa a-recordin Linodesta ja siihen liittyvät kansiot."
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   exit 0
		;;
    esac
done

domain="$1"
record="$2"

koko_domain=$(tee_koko_domain "$domain" "$record")

data="/www-data/$koko_domain"
log="/var/log/$domain/$koko_domain"
portit=/home/lauri/nginx/porttinumerot.txt

# nginx_conf="/home/lauri/nginx/conf.d/$koko_domain.conf"
# [[ ! -e "$nginx_conf" ]] && nginx_conf="$nginx_conf.error"
# [[ -e "$nginx_conf" ]] && laita_portti_takaisin $portit $nginx_conf

rm -rfv "$data"
rm -rfv "$log"
# rm -rfv "$nginx_conf"

domain_id=$(hae_domain_id_linodesta "$domain")
record_id=$(hae_record_id_linodesta "$record" "$domain_id")

domains_komento records-delete "$domain_id" "$record_id"

# podman exec nginx nginx -s reload
