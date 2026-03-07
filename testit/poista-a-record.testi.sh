#!/bin/bash

source /sovellus/scriptit/avustajat.sh

kayttaja=lauri
domain="$(satunnainen_mj).com"
record="$(satunnainen_mj)"
nginx_conf=/home/lauri/nginx/conf.d

# alustus

lisaa-domain-loki.sh "$kayttaja" "$domain"
lisaa-a-record.sh "$kayttaja" "$domain" "$domain"
lisaa-a-record.sh "$kayttaja" "$domain" "$record"

set +e

if poista-a-record.sh; then
    testi_echo "poista-a-record.sh ilman argumentteja ei palauttanut virhettä!"
    virheita+=1
fi

if ! poista-a-record.sh "$domain" "$domain"; then
    testi_echo "poista-a-record.sh palautti virheen!"
    virheita+=1
fi

eihan_ole_olemassa "$LOKIT/$domain/$domain"
eihan_ole_olemassa "$nginx_conf/$domain.conf"


if ! poista-a-record.sh "$record" "$domain"; then
    testi_echo "poista-a-record.sh palautti virheen!"
    virheita+=1
fi

eihan_ole_olemassa "$LOKIT/$domain/$record.$domain"
eihan_ole_olemassa "$nginx_conf/$record.$domain.conf"


exit "$virheita"
