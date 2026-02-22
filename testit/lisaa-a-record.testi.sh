#!/bin/bash

source /sovellus/scriptit/avustajat.sh

kayttaja="$(satunnainen_mj)"
domain="$(satunnainen_mj).com"
record="$(satunnainen_mj)"

nginx_conf=/home/lauri/nginx/conf.d

# alustus

alusta_kayttaja_ja_domain "$kayttaja" "$domain" false
domain_id=$(hae_domain_id_linodesta "$domain")

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

if ! lisaa-a-record.sh "$kayttaja" "$domain" "$domain"; then
    testi_echo "lisaa-a-record palautti virheen!"
    virheita+=1
fi

if ! hae_record_id_linodesta "$domain" "$domain" "$domain_id"; then
    testi_echo "record $domain ei ole Linodessa!"
    virheita+=1
fi

onhan_olemassa "/www-data/$domain"
onhan_olemassa "/var/log/$domain/$domain"
onhan_olemassa "$nginx_conf/$domain.conf"

# 3

if ! lisaa-a-record.sh "$kayttaja" "$domain" "$record"; then
    testi_echo "lisaa-a-record palautti virheen!"
    virheita+=1
fi

if ! hae_record_id_linodesta "$record" "$domain" "$domain_id"; then
    testi_echo "record $record ei ole Linodessa!"
    virheita+=1
fi

onhan_olemassa "/www-data/$record.$domain"
onhan_olemassa "/var/log/$domain/$record.$domain"
onhan_olemassa "$nginx_conf/$record.$domain.conf"

# siivous

domains_komento rm "$domain_id"


exit "$virheita"
