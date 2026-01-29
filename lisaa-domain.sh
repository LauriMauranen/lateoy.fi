#!/bin/bash

set -euo pipefail
shopt -s extglob

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
	   echo "Lisää käyttäjälle domainin ja sille nginx-konfiguraation ja tarvittavat kansiot ja päivittää nginx-kontin."
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   exit 0
		;;
    esac
done

kayttaja="$1"
domain="$2"

# kansiot

data="/www-data/$domain"
log="/var/log/lateoy.fi/$domain"

mkdir -p "$data"
mkdir -p "$log/nginx"

echo "Terve $kayttaja!" > "$data/index.html"

chown "$kayttaja:$kayttaja" "$data" "$log" -R

echo "Luotiin kansiot $data ja $log"

# nginx-konfiguraatio

nginx_conf="/home/lauri/nginx/conf.d/$domain.conf"
nginx_template=/home/lauri/lateoy.fi/conf.d/user-template
portit=/home/lauri/nginx/porttinumerot.txt

backend_portti=$(seuraavaPortti $portit)
[[ -z $backend_portti ]] && exit 1

cert_domain="$domain"
[[ "$cert_domain" =~ lateoy\.fi$ ]] && cert_domain=lateoy.fi

sed_1="s/{{ domain }}/$domain/g"
sed_2="s/{{ cert-domain }}/$cert_domain/g"
sed_3="s/{{ backend-port }}/$backend_portti/g"

sed -e "$sed_1" -e "$sed_2" -e "$sed_3" "$nginx_template" > "$nginx_conf"

chown lauri:lauri "$nginx_conf"

echo "Luotiin $nginx_conf"

if podman exec nginx nginx -t; then
	podman exec nginx nginx -s reload
	echo "Ladattiin uusi nginx-konfiguraatio. https://$domain toimii nyt."
else
	echo "Nginx-konfiguraatio palautti virheen! Tarkista että domainilla on ssl-sertifikaatti ja että domain on lisätty Linoden A/AAAA rekisteriin."
fi
