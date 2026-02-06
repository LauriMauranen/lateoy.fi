#!/bin/bash

set -euo pipefail

laitaPorttiTakaisin() {
    local portit="$1"
    local nginx_conf="$2"
    local domain=${nginx_conf##*/}
    local domain=${domain%.*}

    local portti=$(grep -P "proxy_pass http://$domain:\d{4};" $nginx_conf || :)
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

if [[ ! "$record" =~ "$domain" ]]; then
    echo "Anna record muodossa (record.)domain"
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

[[ "$record" != "$domain" ]] && record="${record%.*}"

cli_token=$(cat /home/lauri/.secrets/linode/cli.token)
domain_id=$(podman compose run --rm -e LINODE_CLI_TOKEN=$cli_token linode-cli \
    domains ls | grep "\s$domain\s" || :)

record_id=

if [[ "$domain_id" =~ [0-9]+ ]]; then
    domain_id="${BASH_REMATCH[0]}"
    record_id=$(podman compose run --rm -e LINODE_CLI_TOKEN=$cli_token linode-cli \
	domains records-list "$domain_id" | grep "\s$record\s" || :)
else
    echo "Domainin hakeminen Linodelta epäonnistui"
    exit 1
fi

if [[ "$record_id" =~ [0-9]+ ]]; then
    record_id="${BASH_REMATCH[0]}"
    podman compose run --rm -e LINODE_CLI_TOKEN="$cli_token" linode-cli \
	domains records-delete "$domain_id" "$record_id"
else
    echo "Recordin hakeminen Linodelta epäonnistui"
fi

podman exec nginx nginx -s reload
