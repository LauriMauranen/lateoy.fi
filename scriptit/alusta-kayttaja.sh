#!/bin/bash

set -euo pipefail

while getopts "h" flag; do
    case "${flag}" in
        h) echo "Käyttö: alusta-kayttaja.sh kayttaja" 
	   echo
	   echo "Luo käyttäjälle tarvittavat kansiot."
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   exit 0
		;;
    esac
done

if ! tarkista_root; then exit 1; fi

kayttaja="$1"

# adduser -s /bin/bash -G users -D "$kayttaja"

home="/home/$kayttaja/"

mkdir -v "$home/.ssh"
touch "$home/.ssh/authorized_keys"

chown "$kayttaja" "$home/.ssh" -R
