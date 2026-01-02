#!/bin/bash

set -euo pipefail

if [[ "$#" == 0 ]]; then
	echo "Anna ainakin yksi käyttäjä"
	exit 1
fi

if [[ $@ =~ (^|\ )- ]]; then
	echo "Komento ei ota vipuja!"
	exit 1
fi

data=/www-data/

for kayttaja in "$@"; do
	if [[ -z "$kayttaja" ]]; then
		echo "Käyttäjänimi puuttuu, ohitetaan"
		continue
	fi

	useradd -s /bin/bash -U -m -G users "$kayttaja" || exit 2

	echo "Luotiin käyttäjä $kayttaja"
	
	home="/home/$kayttaja/"

	mkdir "$home/.ssh"
	touch "$home/.ssh/authorized_keys"

	chown "$kayttaja:$kayttaja" "$home/.ssh" -R

	rm -rf "$data/$kayttaja"
	mkdir "$data/$kayttaja"

	chown "$kayttaja:$kayttaja" "$data/$kayttaja"

	echo "Luotiin tarvittavat kansiot käyttäjälle $kayttaja"
done
