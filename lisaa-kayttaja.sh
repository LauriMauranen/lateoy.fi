#!/bin/bash

set -euo pipefail
shopt -s extglob

kayttaja="$1"

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
echo "Muista asettaa käyttäjälle $kayttaja vielä salasana! (sudo passwd $kayttaja)"
