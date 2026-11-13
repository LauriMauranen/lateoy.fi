#!/bin/bash

source avustajat.sh

kayttaja=lauri
domain="$(satunnainen_mj).com"
record="$(satunnainen_mj)"

# alustus

lisaa-a-record.sh "$kayttaja" "$domain" "$domain"
lisaa-a-record.sh "$kayttaja" "$domain" "$record"

onhan_olemassa "/www-data/$domain"
onhan_olemassa "$LOKIT/$domain"
onhan_olemassa "$NGINX_CONFD/$domain.conf"
onhan_olemassa "/www-data/$record.$domain"
onhan_olemassa "$LOKIT/$record.$domain"
onhan_olemassa "$NGINX_CONFD/$record.$domain.conf"

set +e

if poista-a-record.sh; then
    testi_echo "poista-a-record.sh ilman argumentteja ei palauttanut virhettä!"
fi

if ! poista-a-record.sh "$kayttaja" "$domain" "$domain"; then
    testi_echo "poista-a-record.sh palautti virheen!"
fi

eihan_ole_olemassa "/www-data/$domain"
eihan_ole_olemassa "$LOKIT/$domain"
eihan_ole_olemassa "$NGINX_CONFD/$domain.conf"


if ! poista-a-record.sh "$kayttaja" "$record" "$domain"; then
    testi_echo "poista-a-record.sh palautti virheen!"
fi

eihan_ole_olemassa "/www-data/$record.$domain"
eihan_ole_olemassa "$LOKIT/$record.$domain"
eihan_ole_olemassa "$NGINX_CONFD/$record.$domain.conf"


exit "$virheita"
