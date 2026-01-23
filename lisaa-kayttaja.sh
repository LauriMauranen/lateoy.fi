#!/bin/bash

set -euo pipefail
shopt -s extglob

kayttaja="$1"
domain=

while getopts "hd:" flag; do
    case "${flag}" in
        h) echo "lisaa-kayttaja [ASETUKSET] kayttaja" 
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   echo "  -d DOMAIN     Aseta domain käyttäjälle. Jos tyhjä niin luo domainin kayttaja.lateoy.fi"	
	   exit 0
		;;
        d) domain=$OPTARG ;;
    esac
done

[[ -z "$domain" ]] && domain="$kayttaja.lateoy.fi"

if [[ -z "$kayttaja" ]]; then
	echo "Käyttäjänimi puuttuu, ohitetaan"
	exit 1
fi

if [[ $(grep -c ^$kayttaja: /etc/passwd) > 0 ]]; then
	echo "Käyttäjä $kayttaja on jo olemassa"
	exit 1
fi

useradd -s /bin/bash -U -m -G users "$kayttaja" || exit 1

echo "Luotiin käyttäjä $kayttaja"

home="/home/$kayttaja/"

mkdir "$home/.ssh"
touch "$home/.ssh/authorized_keys"
chown "$kayttaja:$kayttaja" "$home/.ssh" -R

echo "Luotiin kansio .ssh käyttäjälle $kayttaja"

lisaa-domain.sh "$kayttaja" "$domain" 8100
