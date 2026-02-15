#!/bin/bash

source /sovellus/scriptit/avustajat.sh

kayttaja=matti
domain=masa.com

# alustus

alusta_kayttaja_ja_domain "$kayttaja" "$domain"
set +e

# 1

if ! poista-domain.sh "$domain"; then
    testi_echo "poista-domain.sh palautti virheen!"
    virheita+=1
fi

if hae_domain_id_linodesta "$domain"; then
    testi_echo "$domain on vielä Linodessa!"
    virheita+=1
fi

eihan_kansio_ole_olemassa "/var/log/$domain"


exit "$virheita"
