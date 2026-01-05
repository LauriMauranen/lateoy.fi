#!/bin/bash

set -euo pipefail
shopt -s extglob

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
	kansio=${kansio//+(\/)/\/}

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

	if [[ $(grep -c ^$kayttaja: /etc/passwd) > 0 ]]; then
		echo "Käyttäjä $kayttaja on jo olemassa, ohitetaan"
		continue
	fi

	useradd -s /bin/bash -U -m -G users "$kayttaja" || exit 2

	echo "Luotiin käyttäjä $kayttaja"
	
	home="/home/$kayttaja/"

	mkdir "$home/.ssh"
	touch "$home/.ssh/authorized_keys"
	chown "$kayttaja:$kayttaja" "$home/.ssh" -R

	echo "Luotiin kansio .ssh käyttäjälle $kayttaja"

	luoKansio "$data" "$kayttaja"
	luoKansio "$log" "$kayttaja"

	echo "Terve $kayttaja!" > "$data/$kayttaja/index.html"

	mkdir "$log/$kayttaja/nginx"
	chown "$kayttaja:$kayttaja" "$log/$kayttaja" -R
done
