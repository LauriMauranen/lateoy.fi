#!/bin/bash

source /sovellus/scriptit/avustajat.sh

kayttaja=lauri
domain="$(satunnainen_mj).com"
record="$(satunnainen_mj)"

# alustus

lisaa-domain.sh "$kayttaja" "$domain"
lisaa-a-record.sh "$kayttaja" "$domain" "$domain"
lisaa-a-record.sh "$kayttaja" "$domain" "$record"

set +e

# 1

if ! poista-domain.sh "$domain"; then
    testi_echo "poista-domain.sh palautti virheen!"
    virheita+=1
fi

eihan_ole_olemassa "/www-data/$domain"
eihan_ole_olemassa "/www-data/$record.$domain"
eihan_ole_olemassa "$LOKIT/$domain"


exit "$virheita"
