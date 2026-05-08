#!/bin/bash

source avustajat.sh

kotikansionKokoMB=1024

while getopts "hs:" flag; do
    case "${flag}" in
        h) echo "Käyttö: alusta-kayttaja.sh kayttaja" 
	   echo
	   echo "Luo käyttäjälle mountatut kansiot."
	   echo
	   echo "  -s KOKO       Kotikansion koko (MB)."	
	   echo "  -h            Tulosta tämä viesti."	
	   exit 0
		;;

	s) kotikansionKokoMB="$OPTARG"
	    ;;

    esac
done

if ! tarkista_root; then exit 1; fi

kayttaja="${@:$OPTIND:1}"

if [[ "$kotikansionKokoMB" > 2048 ]]; then
    echo "Kotikansio voi olla max 2G"
    exit 1
fi

if grep "$kayttaja:" /etc/passwd; then
    echo "$kayttaja on jo olemassa!"
    exit 1
fi

home="/home/$kayttaja"

luo_mount_kansio "$home" "$kotikansionKokoMB"

useradd "$kayttaja" -s /bin/bash -d "$home"

mkdir -v "$home/.ssh"
touch "$home/.ssh/authorized_keys"

chown "$kayttaja" "$home" -R
chmod 700 "$home"

echo
echo "Muista asettaa käyttäjälle salasana!!!"
echo
