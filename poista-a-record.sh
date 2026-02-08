#!/bin/bash

set -euo pipefail

laitaPorttiTakaisin() {
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

record_on_domain=false
[[ "$record" == "$domain" ]] && record_on_domain=true

if [[ ! "$record" =~ "$domain" ]]; then
    echo "Recordin pitää sisältää domain!"
    exit 1
fi

data="/www-data/$record"
log="/var/log/$domain/$record"
portit=/home/lauri/nginx/porttinumerot.txt

nginx_conf="/home/lauri/nginx/conf.d/$record.conf"
[[ ! -e "$nginx_conf" ]] && nginx_conf="$nginx_conf.error"

[[ -e "$nginx_conf" ]] && laitaPorttiTakaisin $portit $nginx_conf

rm -rf "$data/$record"
rm -rf "$log/$domain/$record"
rm -rf "$nginx_conf"
rm -rf "$nginx_conf"

[[ "$record_on_domain" == false ]] && record="${record%%.*}"

cli_token=$(cat /home/lauri/.secrets/linode/cli.token)
domain_id=$(podman compose run --rm -e LINODE_CLI_TOKEN=$cli_token linode-cli \
    domains ls | grep "\s$domain\s" || :)

record_id=

if [[ "$domain_id" =~ [0-9]+ ]]; then
    domain_id="${BASH_REMATCH[0]}"

    if "$record_on_domain"; then
	record_id=$(podman compose run --rm -e LINODE_CLI_TOKEN=$cli_token linode-cli \
	    domains records-list "$domain_id" | grep "A\s*172" || :)
    else
	record_id=$(podman compose run --rm -e LINODE_CLI_TOKEN=$cli_token linode-cli \
	    domains records-list "$domain_id" | grep -e "\s$record\s" || :)
    fi
else
    echo "Domainin hakeminen Linodelta epäonnistui"
fi

if [[ "$record_id" =~ [0-9]+ ]]; then
    record_id="${BASH_REMATCH[0]}"
    podman compose run --rm -e LINODE_CLI_TOKEN="$cli_token" linode-cli \
	domains records-delete "$domain_id" "$record_id"
else
    echo "Recordin hakeminen Linodelta epäonnistui"
fi

podman exec nginx nginx -s reload
