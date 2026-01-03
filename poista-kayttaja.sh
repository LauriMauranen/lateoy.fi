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

luoKansio() {
	kayttaja="$2"
	kansio="$1/$kayttaja"

	mkdir -p "$kansio"
	chown "$kayttaja:$kayttaja" "$kansio"

	echo "Luotiin kansio $kansio käyttäjälle $kayttaja"
}

data=/www-data/
log=/var/log/

for kayttaja in "$@"; do
	if [[ -z "$kayttaja" ]]; then
		echo "Käyttäjänimi puuttuu, ohitetaan"
		continue
	fi

	userdel -r "$kayttaja" || exit 2

	rm -r "$data/$kayttaja"
	rm -r "$log/$kayttaja"
done
