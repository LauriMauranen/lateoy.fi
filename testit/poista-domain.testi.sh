#!/bin/bash

source /sovellus/scriptit/avustajat.sh

kayttaja="$(satunnainen_mj)"
domain="$(satunnainen_mj).com"
record="$(satunnainen_mj)"

# alustus

alusta_kayttaja_ja_domain "$kayttaja" "$domain" true
lisaa-a-record.sh "$kayttaja" "$domain" "$record"

set +e

# 1

if ! poista-domain.sh "$domain"; then
    testi_echo "poista-domain.sh palautti virheen!"
    virheita+=1
fi

if hae_domain_id_linodesta "$domain"; then
    testi_echo "$domain on vielä Linodessa!"
    virheita+=1
fi

eihan_ole_olemassa "/www-data/$domain"
eihan_ole_olemassa "/www-data/$record.$domain"
eihan_ole_olemassa "/var/log/$domain"

# siivous

poista_domain_linodesta "$domain"


exit "$virheita"
