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

seuraavaPortti() {
    tiedosto="$1"
    local portti=

    # luetaan ensimmäinen rivi
    while read -r rivi; do
      portti="$rivi"
      break
    done <$tiedosto

    if [[ (( $portti > 7999 )) || (( $portti < 8999 )) ]]; then
	# poistetaan portti tiedostosta
	sed '1d' -i $tiedosto
    else
	echo "Portin pitää olla välillä 8000-8999! ($portti)"
	portti=
    fi

    echo $portti
}

while getopts "h" flag; do
    case "${flag}" in
        h) echo "Käyttö: lisaa-domain kayttaja domain" 
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

data="/www-data/$domain"
log="/var/log/lateoy.fi/$domain"
nginx_conf="/home/lauri/nginx/conf.d/$domain.conf"
nginx_template=/home/lauri/lateoy.fi/conf.d/user-template
portit=/home/lauri/nginx/porttinumerot.txt

backend_portti=$(seuraavaPortti $portit)
[[ -z $backend_portti ]] && exit 1

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

if podman exec nginx nginx -t; then
	podman exec nginx nginx -s reload
	echo "Ladattiin uusi nginx-konfiguraatio. $domain täytyy vielä lisätä Linoden A/AAAA rekisteriin."
else
	echo "Nginx-konfiguraatio on virheellinen!"
fi

