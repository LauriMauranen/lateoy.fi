#!/bin/bash

source /sovellus/scriptit/avustajat.sh

kayttaja=lauri
domain="$(satunnainen_mj).com"
record="$(satunnainen_mj)"
nginx_conf=/home/lauri/nginx/conf.d

set +e


huonoja=("masa1!" "makee.$domain" "#¤%&/()" "mama.meme.org")

for r in "${huonoja[@]}"; do
    if lisaa-a-record.sh "$kayttaja" "$domain" "$r"; then
        testi_echo "$r ei ole kelvollinen record!"
        virheita+=1
    fi
done


if lisaa-a-record.sh; then
    testi_echo "lisaa-a-record ilman argumentteja ei palauttanut virhettä!"
    virheita+=1
fi


if ! lisaa-a-record.sh "$kayttaja" "$domain" "$domain"; then
    testi_echo "lisaa-a-record palautti virheen!"
    virheita+=1
fi

onhan_olemassa "/www-data/$domain"
onhan_olemassa "$LOKIT/$domain"
onhan_olemassa "$nginx_conf/$domain.conf"


if ! lisaa-a-record.sh "$kayttaja" "$domain" "$record"; then
    testi_echo "lisaa-a-record palautti virheen!"
    virheita+=1
fi

onhan_olemassa "/www-data/$record.$domain"
onhan_olemassa "$LOKIT/$record.$domain"
onhan_olemassa "$nginx_conf/$record.$domain.conf"


if ! lisaa-a-record.sh -p 8999 "$kayttaja" "$domain" "matti"; then
    testi_echo "lisaa-a-record vivulla -p palautti virheen!"
    virheita+=1
fi

onhan_olemassa "/www-data/matti.$domain"
onhan_olemassa "$LOKIT/matti.$domain"
onhan_olemassa "$nginx_conf/matti.$domain.conf"

if ! grep 8999 "$nginx_conf/matti.$domain.conf"; then
    testi_echo "Portti 8999 ei löydy nginx-konfiguraatiosta!"
    virheita+=1
fi


exit "$virheita"
