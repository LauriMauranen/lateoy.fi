#!/bin/bash

source avustajat.sh

backend_portti=

while getopts "hp:" flag; do
    case "${flag}" in
        h) alkuotsikko "kayttaja domain a-record" 
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

if ! tarkista_root; then exit 1; fi

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

mkdir -pv "$log/nginx" "$data"
echo "Terve $kayttaja!" > "$data/index.html"

chown "$kayttaja" "$data" -R

backend_portti="$(ota_portti_tiedostosta "$PORTIT" "$backend_portti")"
[[ -z "$backend_portti" ]] && echo "Portin numeroa ei saatu!" && exit 1

echo "$backend_portti" > "/home/$kayttaja/.$koko_domain-backend-portti"

nginx_conf="$NGINX_CONFD/$koko_domain.conf"
rakenna_nginx_conf "$domain" "$koko_domain" "$backend_portti" > "$nginx_conf"

# minulle
chown lauri "$nginx_conf" "$log" -R

echo "Luotiin tiedosto $nginx_conf"
echo
echo "Seuraavaksi aja:"
echo "  sudo ufw allow $backend_portti"
echo "  sudo podman exec nginx nginx -s reload"
