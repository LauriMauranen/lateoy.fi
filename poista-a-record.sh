#!/bin/bash

set -euo pipefail

laitaPorttiTakaisin() {
    portit="$1"
    nginx_conf="$2"
    domain=${nginx_conf##*/}
    domain=${domain%.*}

    local portti=$(grep -P "proxy_pass http://$domain:\d{4};" $nginx_conf || :)
    portti=${portti##*:}
    portti=${portti%;}

    if [[ -z $portti ]]; then
	echo "Portti on tyhjä merkkijono!"
    else 
	echo "$portti" >> $portit
    fi
}

while getopts "h" flag; do
    case "${flag}" in
        h) echo "Käyttö: poista-a-record domain domain-id a-record" 
	   echo
	   echo "Poistaa a-recordin Linodesta ja siihen liittyvät kansiot."
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   exit 0
		;;
    esac
done

domain="$1"
domain_id="$2"
record="$3"

if [[ "$domain_id" =~ [a-zA-Z] ]]; then
    echo "'domain-id' pitää olla kokonaisluku! ($domain_id)"
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

[[ "$record" =~ "$domain" && "$record" != "$domain" ]] \
    && record="${record%.*}"

cli_token=$(cat /home/lauri/.secrets/linode/cli.token)

podman compose run --rm -e LINODE_CLI_TOKEN="$cli_token" linode-cli \
    domains records-delete "$domain_id" "$record"

podman exec nginx nginx -s reload
