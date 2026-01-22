#!/bin/bash

set -euo pipefail

while getopts "h" flag; do
    case "${flag}" in
        h) echo "Käyttö: poista-domain domain1 domain2 ..." 
	   echo
	   echo "Poistaa domainin nginx-konfiguraation, lokitus-kansion, www-data -kansion ja ajaa 'nginx -s reload'."
	   echo
	   echo "  -h            Tulosta tämä viesti."	
		;;
    esac
done

data=/www-data/
log=/var/log/lateoy.fi/
nginx_conf=/home/lauri/nginx/conf.d/

for domain in "$@"; do
	if [[ -z "$domain" ]]; then
		echo "Domain puuttuu, ohitetaan"
		continue
	fi

	if [[ ! -e "$nginx_conf/$domain" ]]; then
		echo "Domainia $domain ei ole olemassa, ohitetaan"
		continue
	fi

	rm -r "$data/$domain"
	rm -r "$log/$domain"
	rm -r "$nginx_conf/$domain"
done

podman exec nginx nginx -s reload
