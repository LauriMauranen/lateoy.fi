#!/bin/bash

set -euo pipefail

source avustajat.sh

# 1

set +e
if lisaa-kayttaja.sh; then
    set -e
    testi_echo "lisaa-kayttaja.sh vaatii käyttäjänimen!"
    virheita+=1
fi

# 2

kayttaja=matti

set +e
if ! lisaa-kayttaja.sh "$kayttaja"; then
    set -e
    testi_echo "lisaa-kayttaja.sh palautti virheen!"
    virheita+=1
fi

# 3

ssh="/home/$kayttaja/.ssh/authorized_keys" 

if [[ ! -e "$ssh" ]]; then
    testi_echo "Tiedosto $ssh puuttuu!"
    virheita+=1
fi


exit "$virheita"
