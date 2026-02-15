#!/bin/bash

source /sovellus/scriptit/avustajat.sh
set +e

kayttaja=matti

# siivous

deluser --remove-home "$kayttaja"

# 1

if ! lisaa-kayttaja.sh "$kayttaja"; then
    testi_echo "lisaa-kayttaja.sh palautti virheen!"
    virheita+=1
fi

# 2

ssh="/home/$kayttaja/.ssh/authorized_keys" 

if [[ ! -e "$ssh" ]]; then
    testi_echo "Tiedosto $ssh puuttuu!"
    virheita+=1
fi


exit "$virheita"
