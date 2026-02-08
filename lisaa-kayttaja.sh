#!/bin/bash

set -euo pipefail

while getopts "h" flag; do
    case "${flag}" in
        h) echo "lisaa-kayttaja kayttaja" 
	   echo
	   echo "Luo käyttäjän ja .ssh-kansion valmiiksi."
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   exit 0
		;;
    esac
done

kayttaja="$1"

useradd -s /bin/bash -U -m -G users "$kayttaja" || exit 1

echo "Luotiin käyttäjä $kayttaja"

home="/home/$kayttaja/"

mkdir -v "$home/.ssh"
touch "$home/.ssh/authorized_keys"

chown "$kayttaja:$kayttaja" "$home/.ssh" -R

echo "Muista asettaa käyttäjälle $kayttaja vielä salasana! (sudo passwd $kayttaja)"
