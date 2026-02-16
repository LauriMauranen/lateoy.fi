#!/bin/bash

source /sovellus/scriptit/avustajat.sh

kayttaja=matti
domain=masa.com

# alustus

siivoa_kayttaja_ja_domain "$kayttaja" "$domain" 
lisaa-kayttaja.sh "$kayttaja" 

set +e

# 1

if ! lisaa-domain.sh -r "$kayttaja" "$domain"; then
    testi_echo "lisaa-domain.sh palautti virheen!"
    virheita+=1
fi

onhan_kansio_olemassa "/var/log/$domain/$domain"
onhan_kansio_olemassa "/www-data/$domain"

domain_id=$(hae_domain_id_linodesta "$domain")

if [[ -z "$domain_id" ]]; then
    testi_echo "Domain $domain ei löydy Linodesta!"
    virheita+=1
fi

if ! hae_record_id_linodesta "$domain" "$domain_id"; then
    testi_echo "Record $domain ei löydy Linodesta!"
    virheita+=1
fi


exit "$virheita"
