#!/bin/bash

set -euo pipefail
shopt -s extglob

luoKansio() {
	kansio=${1//+(\/)/\/}
	kayttaja="$2"

	mkdir -p "$kansio"
	chown "$kayttaja:$kayttaja" "$kansio"

	echo "Luotiin kansio $kansio käyttäjälle $kayttaja"
}

while getopts "h" flag; do
    case "${flag}" in
        h) echo "Käyttö: lisaa-domain kayttaja domain backend-portti" 
	   echo
	   echo "Lisää domainille nginx-konfiguraation, lokitus-kansion, www-data -kansion ja ajaa 'nginx -s reload'."
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   exit 0
		;;
    esac
done

kayttaja="$1"
domain="$2"
backend_portti="$3"

data="/www-data/$domain"
log="/var/log/lateoy.fi/$domain"
nginx_conf="/home/lauri/nginx/conf.d/$domain.conf"
nginx_template=/home/lauri/lateoy.fi/conf.d/user-template

cert_domain="$domain"
[[ "$cert_domain" =~ lateoy\.fi ]] && cert_domain=lateoy.fi

luoKansio "$data" "$kayttaja" 
luoKansio "$log" "$kayttaja" 

mkdir "$log/nginx"
chown "$kayttaja:$kayttaja" "$log" -R

echo "Terve $kayttaja!" > "$data/index.html"

sed_1="s/{{ domain }}/$domain/g"
sed_2="s/{{ cert-domain }}/$cert_domain/g"
sed_3="s/{{ backend-port }}/$backend_portti/g"

sed -e "$sed_1" -e "$sed_2" -e "$sed_3" "$nginx_template" > "$nginx_conf"

chown lauri:lauri "$nginx_conf"

echo "Luotiin $nginx_conf"

podman exec nginx nginx -s reload

echo "Ladattiin uusi nginx-konfiguraatio. $domain täytyy vielä lisätä Linoden A/AAAA rekisteriin."
