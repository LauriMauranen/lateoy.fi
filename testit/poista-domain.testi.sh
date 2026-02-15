#!/bin/bash

source /sovellus/scriptit/avustajat.sh
set +e

kayttaja=matti
domain=masa.com

#siivous

deluser --remove-home "$kayttaja"
poista-domain.sh "$domain"

set -e
lisaa-kayttaja.sh "$kayttaja"
lisaa-domain.sh "$kayttaja" "$domain"
set +e

# 1

if ! poista-domain.sh "$domain"; then
    testi_echo "poista-domain.sh palautti virheen!"
    virheita+=1
fi

# 2

if hae_domain_id_linodesta "$domain"; then
    testi_echo "$domain on vielä Linodessa!"
    virheita+=1
    poista_domain_linodesta "$domain"
fi

# 3

log="/var/log/$domain"

if [[ -e "$log" ]]; then
    testi_echo "Kansio $log on vielä olemassa!"
    virheita+=1
    rm -rf "$log"
fi


exit "$virheita"
