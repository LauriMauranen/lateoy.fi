#!/bin/bash

set -euo pipefail

laitaPorttiTakaisin() {
    portit="$1"
    nginx_conf="$2"
    domain=${nginx_conf##*/}
    domain=${domain%.*}

    local portti=$(grep -P "proxy_pass http://$domain:\d{4};" $nginx_conf)
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
        h) echo "Käyttö: poista-domain domain1 domain2 ..." 
	   echo
	   echo "Poistaa domainin nginx-konfiguraation, lokitus-kansion, www-data -kansion ja ajaa 'nginx -s reload'."
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   exit 0
		;;
    esac
done

data=/www-data/
log=/var/log/lateoy.fi/
portit=/home/lauri/nginx/porttinumerot.txt

for domain in "$@"; do
	if [[ -z "$domain" ]]; then
		echo "Domain puuttuu, ohitetaan"
		continue
	fi

	nginx_conf="/home/lauri/nginx/conf.d/$domain.conf"

	if [[ ! -e "$nginx_conf" ]]; then
		echo "Domainia $domain ei ole olemassa, ohitetaan"
		continue
	fi

	laitaPorttiTakaisin $portit $nginx_conf

	rm -r "$data/$domain"
	rm -r "$log/$domain"
	rm -r "$nginx_conf"

	echo "Poistettin domainiin $domain liittyvät kansiot ja tiedostot."
done

podman exec nginx nginx -s reload

echo "Ladattiin uusi nginx-konfiguraatio."
