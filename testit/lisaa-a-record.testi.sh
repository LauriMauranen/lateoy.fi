#!/bin/bash

source /sovellus/scriptit/avustajat.sh

kayttaja=matti
domain=masa.com

# siivous

set +e
deluser --remove-home "$kayttaja"
poista-domain.sh "$domain"

set -e
lisaa-kayttaja.sh "$kayttaja"
lisaa-domain.sh "$kayttaja" "$domain"
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

# record1=terve

# if ! lisaa-a-record.sh "$kayttaja" "$domain" "$record1"; then
#     testi_echo "lisaa-a-record palautti virheen!"
#     virheita+=1
# fi

# 3

# 4

#siivous



exit "$virheita"
