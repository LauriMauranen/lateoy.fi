#!/bin/bash

source /sovellus/scriptit/avustajat.sh

kayttaja="$(satunnainen_mj)"
domain="$(satunnainen_mj).com"
record="$(satunnainen_mj)"

nginx_conf=/home/lauri/nginx/conf.d

# alustus

alusta_kayttaja_ja_domain "$kayttaja" "$domain" true
lisaa-a-record.sh "$kayttaja" "$domain" "$record"
domain_id="$(hae_domain_id_linodesta "$domain")"

set +e

if poista-a-record.sh -k "$record" "$domain" "$domain_id"; then
    testi_echo "Vivun -k ja domain_id:n pitää palauttaa virhe!"
    virheita+=1
fi


if ! poista-a-record.sh "$domain" "$domain" "$domain_id"; then
    testi_echo "poista-a-record.sh palautti virheen!"
    virheita+=1
fi

if hae_record_id_linodesta "$domain" "$domain" "$domain_id"; then
    testi_echo "Record $domain on vielä Linodessa!"
    virheita+=1
fi

eihan_ole_olemassa "/www-data/$domain"
eihan_ole_olemassa "/var/log/$domain/$domain"
eihan_ole_olemassa "$nginx_conf/$domain.conf"


if ! poista-a-record.sh -k "$record" "$domain"; then
    testi_echo "poista-a-record.sh palautti virheen!"
    virheita+=1
fi

if ! hae_record_id_linodesta "$record" "$domain" "$domain_id"; then
    testi_echo "Record $record ei löydy Linodesta!"
    virheita+=1
fi

eihan_ole_olemassa "/www-data/$record.$domain"
eihan_ole_olemassa "/var/log/$domain/$record.$domain"
eihan_ole_olemassa "$nginx_conf/$record.$domain.conf"


if ! poista-a-record.sh "$record" "$domain" "$domain_id"; then
    testi_echo "poista-a-record.sh palautti virheen!"
    virheita+=1
fi

if hae_record_id_linodesta "$record" "$domain" "$domain_id"; then
    testi_echo "Record $record on vielä Linodessa!"
    virheita+=1
fi

# siivous

domains_komento rm "$domain_id"


exit "$virheita"
