#!/bin/bash

source avustajat.sh

# halutaan että ajetaan loppuun asti, muuten jää testikäyttäjä
# roikkumaan mahdollisesti
set +e

virhe=0

kayttaja="testikayttaja"

luo-kayttaja.sh -s 10 "$kayttaja"

portti="$(head -n 1 $PORTIT)"
lisaa-a-record.sh "$kayttaja" "$LATE_DOMAIN" "$kayttaja"

ufw allow "$portti"
ufw reload

podman exec nginx nginx -s reload

sleep 5

[[ ! "$(curl "https://$kayttaja.$LATE_DOMAIN")" =~ "Terve $kayttaja!" ]] && virhe=1

poista-a-record.sh "$kayttaja" "$kayttaja" "$LATE_DOMAIN"
poista-kayttaja.sh "$kayttaja"

ufw delete allow "$portti"
ufw reload

podman exec nginx nginx -s reload

[[ "$virhe" == 1 ]] && echo "url '$kayttaja.$LATE_DOMAIN' ei palauta oikeaa dataa!!!"
exit "$virhe"
