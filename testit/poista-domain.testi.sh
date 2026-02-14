#!/bin/bash

source /sovellus/scriptit/avustajat.sh

kayttaja=matti
domain=masa.com

lisaa-kayttaja.sh "$kayttaja"
lisaa-domain.sh "$kayttaja" "$domain"

set +e

# 1

if ! poista-domain.sh "$domain"; then
    testi_echo "poista-domain.sh palautti virheen!"
    virheita+=1
fi

# 2

if hae_domain_id "$domain"; then
    testi_echo "$domain on vielä Linodessa!"
    virheita+=1
fi

# 3

log="/var/log/$domain"

if [[ -e "$log" ]]; then
    testi_echo "Kansio $log on vielä olemassa!"
    virheita+=1
fi

#siivous

set -e

deluser --remove-home "$kayttaja"
rm -rf "$log"
poista_domain_linodesta "$domain"
echo hello


exit "$virheita"
