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
    echo "Käyttäjää $kayttaja ei ole olemassa!"
    exit 1
fi

if [[ -z "$record" || -z "$domain" ]]; then
    echo "'a-record' ja 'domain' ovat pakollisia!"
    exit 1 
fi

koko_domain=$(tee_koko_domain "$domain" "$record")

if ! ls -l /www-data | grep "$koko_domain" | cut -f3 -d' '; then
    echo "Käyttäjällä $kayttaja ei ole osoitetta $koko_domain"
    exit 1 
fi

nginx_conf="$NGINX_CONFD/$koko_domain.conf"
[[ ! -e "$nginx_conf" ]] && nginx_conf="$nginx_conf.error"

if [[ -e "$nginx_conf" ]]; then
    portti="$(laita_portti_takaisin "$nginx_conf")"
    echo "$portti" >> "$PORTIT"
    p="/home/$kayttaja/$KAYTTAJAN_PORTIT"
    w=$(wc -l "${p}")
    # poistetaan porttirivi. jos vain yksi rivi poistetaan koko tiedosto.
    if [[ "${w% *}" -gt 1 ]]; then
	grep -v "$portti" "$p" > "$p-tmp"
	cat "$p-tmp" > "$p"
	rm "$p-tmp"
    else
	rm "${p}"
    fi
    echo "Seuraavaksi aja:"
    echo "  sudo ufw delete allow $portti"
    echo "  sudo podman exec nginx nginx -s reload"
fi

rm -rfv "$LOKIT/$koko_domain" "/www-data/$koko_domain" "$nginx_conf"
