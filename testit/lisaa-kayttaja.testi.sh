#!/bin/bash

source /sovellus/scriptit/avustajat.sh
set +e

# 1

if lisaa-kayttaja.sh; then
    testi_echo "lisaa-kayttaja.sh vaatii käyttäjänimen!"
    virheita+=1
fi

# 2

kayttaja=matti

if ! lisaa-kayttaja.sh "$kayttaja"; then
    testi_echo "lisaa-kayttaja.sh palautti virheen!"
    virheita+=1
fi

# 3

ssh="/home/$kayttaja/.ssh/authorized_keys" 

if [[ ! -e "$ssh" ]]; then
    testi_echo "Tiedosto $ssh puuttuu!"
    virheita+=1
fi


# siivous

deluser --remove-home "$kayttaja"


exit "$virheita"
