#!/bin/bash

set -euo pipefail

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

domains_komento() {
    podman compose run --rm -e LINODE_CLI_TOKEN=$cli_token linode-cli domains \
	--text "$@"
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

record_on_domain=false
koko_domain="$domain"

if [[ "$record" == "$domain" ]]; then
    record_on_domain=true
elif [[ "$record" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    koko_domain="$record.$domain"
else
    "Record on epäkelpo!"
    exit 1
fi

data="/www-data/$koko_domain"
log="/var/log/$domain/$koko_domain"
portit=/home/lauri/nginx/porttinumerot.txt

nginx_conf="/home/lauri/nginx/conf.d/$koko_domain.conf"
[[ ! -e "$nginx_conf" ]] && nginx_conf="$nginx_conf.error"
[[ -e "$nginx_conf" ]] && laita_portti_takaisin $portit $nginx_conf

rm -rfv "$data"
rm -rfv "$log"
rm -rfv "$nginx_conf"

cli_token=$(cat /home/lauri/.secrets/linode/cli.token)

domain_id=$(domains_komento ls | grep "\s$domain\s" || :)

record_id=

if [[ "$domain_id" =~ [0-9]+ ]]; then
    domain_id="${BASH_REMATCH[0]}"

    if "$record_on_domain"; then
	record_id=$(domains_komento records-list "$domain_id" | grep "A\s*172" || :)
    else
	record_id=$(domains_komento records-list "$domain_id" | grep -e "\s$record\s" || :)
    fi
else
    echo "Domainin hakeminen Linodelta epäonnistui"
fi

if [[ "$record_id" =~ [0-9]+ ]]; then
    record_id="${BASH_REMATCH[0]}"
    domains_komento records-delete "$domain_id" "$record_id"
else
    echo "Recordin hakeminen Linodelta epäonnistui"
fi

podman exec nginx nginx -s reload
