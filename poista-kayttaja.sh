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
log=/var/log/

for kayttaja in "$@"; do
	if [[ -z "$kayttaja" ]]; then
		echo "Käyttäjänimi puuttuu, ohitetaan"
		continue
	fi

	if [[ $(grep -c ^$kayttaja: /etc/passwd) == 0 ]]; then
		echo "Käyttäjää $kayttaja ei ole olemassa, ohitetaan"
		continue
	fi

	userdel -r "$kayttaja" || exit 2

	rm -r "$data/$kayttaja"
	rm -r "$log/$kayttaja"
done
