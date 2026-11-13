#!/bin/bash

source avustajat.sh

koko_oletus=1024
kotikansion_koko_MB=$koko_oletus

while getopts "hs:" flag; do
    case "${flag}" in
        h) alkuotsikko "kayttaja" 
	   echo
	   echo "Luo käyttäjälle mountatut kansiot."
	   echo
	   echo "  -s KOKO (MB)  Kotikansion koko (oletus $koko_oletus)."	
	   echo "  -h            Tulosta tämä viesti."	
	   exit 0
		;;

	s) kotikansion_koko_MB="$OPTARG"
	    ;;

    esac
done

if ! tarkista_root; then exit 1; fi

kayttaja="${@:$OPTIND:1}"

if [[ "$kotikansion_koko_MB" > "$MAX_KOTI_KOKO" ]]; then
    virhe "Kotikansio voi olla max $MAX_KOTI_KOKO MB"
fi

if grep "$kayttaja:" /etc/passwd; then
    virhe "$kayttaja on jo olemassa!"
fi

home="/home/$kayttaja"

luo_mount_kansio "$home" "$kotikansion_koko_MB"

useradd "$kayttaja" -s /bin/bash -d "$home"

mkdir -v "$home/.ssh" "$home/$TIETOJA_KAYTTAJALLE"
touch "$home/.ssh/authorized_keys"

rakenna_kayttoohje "$kayttaja" "$kotikansion_koko_MB" > "$home/$KAYTTOOHJE"

chown "$kayttaja" "$home" -R
chmod 700 "$home"

echo
echo "Aja seuraavaksi sudo passwd $kayttaja"
echo
