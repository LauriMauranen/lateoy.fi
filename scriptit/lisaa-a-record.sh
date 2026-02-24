#!/bin/bash

source avustajat.sh

backend_portti=

while getopts "hp" flag; do
    case "${flag}" in
        h) echo "Käyttö: lisaa-a-record kayttaja domain record" 
	   echo
	   echo "Lisää A-recordin domainille Linodeen ja tekee sille nginx-konfiguraation ja tarvittavat kansiot ja päivittää nginx-kontin."
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   echo "  -p            Aseta backend portti jos saatavilla."	
	   exit 0
		;;
	p) backend_portti="$OPTARG" 
		;;
    esac
done

kayttaja="${@:$OPTIND:1}"
domain="${@:$OPTIND+1:1}"
record="${@:$OPTIND+2:1}"

koko_domain=$(tee_koko_domain "$domain" "$record")

# kansiot

data="/www-data/$koko_domain"
log="/var/log/$domain/$koko_domain"

mkdir -p -v "$data" "$log/nginx"
echo "Terve $kayttaja!" > "$data/index.html"

chown "$kayttaja" "$data" "$log" -R

portit=/home/lauri/nginx/porttinumerot.txt

backend_portti="$(ota_portti_tiedostosta "$portit" "$backend_portti")"
[[ -z "$backend_portti" ]] && echo "Portin numeroa ei saatu!" && exit 1

nginx_conf="/home/lauri/nginx/conf.d/$koko_domain.conf"
nginx_template=/home/lauri/lateoy.fi/conf.d/user-template

rakenna_nginx_conf "$domain" "$koko_domain" "$backend_portti" "$nginx_template" \
    > "$nginx_conf"
chown lauri "$nginx_conf"

ip=172.234.123.168 
email=lauri.mauranen@gmail.com

domain_id=$(hae_domain_id_linodesta "$domain")
domains_komento records-create --name "$record" --type A --target "$ip" "$domain_id"

[[ "$TESTIAJO" == true ]] && exit 0

echo "Odotetaan 10 sekuntia..."
sleep 10

if podman exec nginx nginx -t; then
    podman exec nginx nginx -s reload
    echo "Ladattiin uusi nginx-konfiguraatio. https://$koko_domain toimii nyt."
else
    mv "$nginx_conf" "$nginx_conf.error"
    echo "Nginx-konfiguraatio palautti virheen! Löytyykö domainilta ssl-sertifikaatti?"
fi
