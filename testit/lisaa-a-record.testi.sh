#!/bin/bash

source /sovellus/scriptit/avustajat.sh

kayttaja=matti
domain=masa.com

lisaa-kayttaja.sh "$kayttaja"
lisaa-domain.sh "$kayttaja" "$domain"

set +e

# 1


huonoja=("masa1!" "makee.$domain" "#¤%&/()" "mama.meme.org")

for r in "${huonoja[@]}"; do
    if lisaa-a-record.sh "$kayttaja" "$domain" ; then
        testi_echo ""
        virheita+=1
    fi
done

# 2

# 3

# 4

#siivous

deluser --remove-home "$kayttaja"
poista_domain "$domain"


exit "$virheita"
