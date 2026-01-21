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
        h) echo "Kaytto: lisaa-domain kayttaja domain backend-portti" 
	   echo
	   echo "Lisää domainille nginx-konfiguraation, lokitus-kansion, www-data -kansion ja ajaa 'nginx -s reload'."
	   echo
	   echo "  -h            Tulosta tämä viesti."	
		;;
    esac
done

kayttaja="$1"
domain="$2"
backend_portti="$3"

data=/www-data/
log=/var/log/lateoy.fi/
nginx_conf="/home/lauri/nginx/conf.d/$domain.conf"
nginx_template=/home/lauri/lateoy.fi/conf.d/user-template

cert_domain="$domain"
[[ "$cert_domain" =~ lateoy\.fi ]] && cert_domain=lateoy.fi

luoKansio "$data" "$kayttaja" "$domain"
luoKansio "$log" "$kayttaja" "$domain"

echo "Terve $kayttaja!" > "$data/$domain/index.html"

mkdir "$log/$domain/nginx"
chown "$kayttaja:$kayttaja" "$log/$domain" -R

sed_1="s/{{ domain }}/$domain/g"
sed_2="s/{{ cert-domain }}/$cert_domain/g"
sed_3="s/{{ backend-port }}/${backend_portti}/g"

sed -e "$sed_1" -e "$sed_2" -e "$sed_3" "$nginx_template" > "$nginx_conf"

echo "Luotiin $nginx_conf"

podman exec nginx nginx -s reload

echo "Ladattiin uusi nginx-konfiguraatio. https://$domain toimii nyt."
