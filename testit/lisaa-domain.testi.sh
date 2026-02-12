#!/bin/bash

set -euo pipefail

source ../scriptit/avustajat.sh

# 1

set +e
if lisaa-domain.sh; then
    testi_echo "lisaa-domain.sh vaatii käyttäjän ja domainin!"
    virheita+=1
fi
set -e

# 2

kayttaja=matti
domain=masa.com

set +e
if ! lisaa-kayttaja.sh "$kayttaja" && lisaa-domain.sh "$domain" "$kayttaja"; 
then
    testi_echo "Joko käyttäjän tai domainin lisääminen epäonnistui!"
    virheita+=1
fi
set -e

# 3

log="/var/log/$domain"

if [[ ! -e "$log" ]]; then
    testi_echo "Kansio $log puuttuu!"
    virheita+=1
fi

# 4

log="/var/log/$domain"

if [[ ! -e "$log" ]]; then
    testi_echo "Kansio $log puuttuu!"
    virheita+=1
fi

exit "$virheita"
