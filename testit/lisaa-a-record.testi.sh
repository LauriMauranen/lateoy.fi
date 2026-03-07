#!/bin/bash

source /sovellus/scriptit/avustajat.sh

kayttaja=lauri
domain="$(satunnainen_mj).com"
record="$(satunnainen_mj)"
nginx_conf=/home/lauri/nginx/conf.d

# alustus

lisaa-domain.sh  "$kayttaja" "$domain"

set +e

# 1

huonoja=("masa1!" "makee.$domain" "#¤%&/()" "mama.meme.org")

for r in "${huonoja[@]}"; do
    if lisaa-a-record.sh "$kayttaja" "$domain" "$r"; then
        testi_echo "$r ei ole kelvollinen record!"
        virheita+=1
    fi
done

# 2

if lisaa-a-record.sh; then
    testi_echo "lisaa-a-record ilman argumentteja ei palauttanut virhettä!"
    virheita+=1
fi

if ! lisaa-a-record.sh "$kayttaja" "$domain" "$domain"; then
    testi_echo "lisaa-a-record palautti virheen!"
    virheita+=1
fi

onhan_olemassa "/www-data/$domain"
onhan_olemassa "$LOKIT/$domain/$domain"
onhan_olemassa "$nginx_conf/$domain.conf"

# 3

if ! lisaa-a-record.sh "$kayttaja" "$domain" "$record"; then
    testi_echo "lisaa-a-record palautti virheen!"
    virheita+=1
fi

onhan_olemassa "/www-data/$record.$domain"
onhan_olemassa "$LOKIT/$domain/$record.$domain"
onhan_olemassa "$nginx_conf/$record.$domain.conf"


exit "$virheita"
