#!/bin/bash

source /sovellus/scriptit/avustajat.sh

kayttaja=lauri
domain="$(satunnainen_mj).com"
record="$(satunnainen_mj)"

# alustus

lisaa-a-record.sh "$kayttaja" "$domain" "$domain"
lisaa-a-record.sh "$kayttaja" "$domain" "$record"

set +e

# 1

if poista-domain.sh; then
    testi_echo "poista-domain.sh ilman argumentteja ei palauttanut virhettä!"
    virheita+=1
fi

if ! poista-domain.sh "$domain"; then
    testi_echo "poista-domain.sh palautti virheen!"
    virheita+=1
fi

eihan_ole_olemassa "$LOKIT/$domain"
eihan_ole_olemassa "$NGINX_CONFD/$domain.conf"
eihan_ole_olemassa "$NGINX_CONFD/$record.$domain.conf"


exit "$virheita"
