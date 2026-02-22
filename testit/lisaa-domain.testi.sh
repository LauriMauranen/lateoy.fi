#!/bin/bash

source /sovellus/scriptit/avustajat.sh

kayttaja="$(satunnainen_mj)"
domain="$(satunnainen_mj).com"

# alustus

lisaa-kayttaja.sh "$kayttaja" 

set +e

# 1

if ! lisaa-domain.sh -r "$kayttaja" "$domain"; then
    testi_echo "lisaa-domain.sh palautti virheen!"
    virheita+=1
fi

onhan_olemassa "/var/log/$domain/$domain"
onhan_olemassa "/www-data/$domain"

domain_id=$(hae_domain_id_linodesta "$domain")

if [[ -z "$domain_id" ]]; then
    testi_echo "Domain $domain ei löydy Linodesta!"
    virheita+=1
fi

if ! hae_record_id_linodesta "$domain" "$domain" "$domain_id"; then
    testi_echo "Record $domain ei löydy Linodesta!"
    virheita+=1
fi

# siivous

domains_komento rm "$domain_id"

exit "$virheita"
