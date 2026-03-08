#!/bin/bash

source avustajat.sh

if ! tarkista_root; then exit 1; fi

backend_portti=

while getopts "hp" flag; do
    case "${flag}" in
        h) echo "Käyttö: lisaa-a-record.sh [asetukset] kayttaja domain a-record" 
	   echo
	   echo "Lisää recordille nginx-konfiguraation ja tarvittavat kansiot."
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

if [[ -z "$kayttaja" || -z "$record" || -z "$domain" ]]; then
    echo "'kayttaja', 'a-record' ja 'domain' ovat pakollisia!"
    exit 1 
fi

koko_domain=$(tee_koko_domain "$domain" "$record")

# kansiot

data="/www-data/$koko_domain"
log="$LOKIT/$koko_domain"

mkdir -p -v "$data" "$log/nginx"
echo "Terve $kayttaja!" > "$data/index.html"

chown "$kayttaja" "$data" "$log" -R

backend_portti="$(ota_portti_tiedostosta "$PORTIT" "$backend_portti")"
[[ -z "$backend_portti" ]] && echo "Portin numeroa ei saatu!" && exit 1

nginx_conf="/home/lauri/nginx/conf.d/$koko_domain.conf"
nginx_template=/home/lauri/lateoy.fi/conf.d/user-template

rakenna_nginx_conf "$domain" "$koko_domain" "$backend_portti" "$nginx_template" \
    > "$nginx_conf"
