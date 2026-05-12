#!/bin/bash

source avustajat.sh

virhe=0

kayttaja="testikayttaja"
domain="lateoy.fi"

luo-kayttaja.sh -s 10 "$kayttaja"

portti="$(lisaa-a-record.sh "$kayttaja" "$domain" "$kayttaja")"
portti="${portti##* }"

ufw allow "$portti"
ufw reload

podman exec nginx nginx -s reload

[[ ! "$(curl "$kayttaja.$domain")" =~ "Terve $kayttaja!" ]] && virhe=1

poista-a-record.sh "$kayttaja" "$domain"
poista-kayttaja.sh "$kayttaja"

ufw deny "$portti"
ufw reload

podman exec nginx nginx -s reload

[[ "$virhe" == 1 ]] && echo "url '$kayttaja.$domain' ei palauta oikeaa dataa!!!"
exit "$virhe"
