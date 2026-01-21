#!/bin/bash

set -euo pipefail
shopt -s extglob

luoKansio() {
	kayttaja="$2"
	domain="$3"

	kansio="$1/$domain"
	kansio=${kansio//+(\/)/\/}

	mkdir -p "$kansio"
	chown "$kayttaja:$kayttaja" "$kansio"

	echo "Luotiin kansio $kansio käyttäjälle $kayttaja"
}

while getopts "h" flag; do
    case "${flag}" in
        h) echo "lisaa-domain kayttaja domain" 
	   echo "Lisää domainille nginx-konfiguraation, lokitus-kansion, www-data -kansion ja ajaa 'nginx -s reload'."
	   echo "  -h            Tulosta tämä viesti."	
		;;
    esac
done

kayttaja="$1"
domain="$2"

data=/www-data/
log=/var/log/lateoy.fi/
nginx_template=/home/lauri/lateoy.fi/conf.d/user-template

luoKansio "$data" "$kayttaja" "$domain"
luoKansio "$log" "$kayttaja" "$domain"

echo "Terve $kayttaja!" > "$data/$domain/index.html"

mkdir "$log/$domain/nginx"
chown "$kayttaja:$kayttaja" "$log/$domain" -R
