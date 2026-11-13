#!/bin/bash

source avustajat.sh

while getopts "h" flag; do
    case "${flag}" in
        h) alkuotsikko "kayttaja a-record domain" 
	   echo
	   echo "Poistaa a-recordin kansiot ja tiedostot."
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   exit 0
		;;
    esac
done

if ! tarkista_root; then exit 1; fi

kayttaja="${@:$OPTIND:1}"
record="${@:$OPTIND+1:1}"
domain="${@:$OPTIND+2:1}"

if ! grep "$kayttaja:" /etc/passwd; then
    virhe "Käyttäjää $kayttaja ei ole olemassa!"
fi

if [[ -z "$record" || -z "$domain" ]]; then
    virhe "'a-record' ja 'domain' ovat pakollisia!"
fi

koko_domain=$(tee_koko_domain "$domain" "$record")

if ! ls -l /www-data | grep "$koko_domain" | cut -f3 -d' '; then
    virhe "Käyttäjällä $kayttaja ei ole osoitetta $koko_domain"
fi

nginx_conf="$NGINX_CONFD/$koko_domain.conf"
portti="$(lue_portti "$nginx_conf")"
[[ -z "$portti" ]] && virhe "Porttia ei saatu!"
echo "$portti" >> "$PORTIT"
poista_porttirivi_tai_koko_tiedosto \
    "/home/$kayttaja/$KAYTTAJAN_PORTIT" "${portti}" 

echo "Seuraavaksi aja:"
echo "  sudo ufw delete allow $portti"
echo "  sudo podman exec nginx nginx -s reload"

rm -rfv "$LOKIT/$koko_domain" "/www-data/$koko_domain" "$nginx_conf"

# vanha lokikansio
rm -rfv "/var/log/sovelluslokit/$koko_domain"
