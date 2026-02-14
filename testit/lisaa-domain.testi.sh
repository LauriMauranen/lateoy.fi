#!/bin/bash

source /sovellus/scriptit/avustajat.sh
set +e

# 1

if lisaa-domain.sh; then
    testi_echo "lisaa-domain.sh vaatii käyttäjän ja domainin!"
    virheita+=1
fi

# 2

kayttaja=matti
domain=masa.com

if ! (lisaa-kayttaja.sh "$kayttaja" && lisaa-domain.sh "$kayttaja" "$domain"); 
then
    testi_echo "Joko käyttäjän tai domainin lisääminen epäonnistui!"
    virheita+=1
fi

# 3

log="/var/log/$domain"

if [[ ! -e "$log" ]]; then
    testi_echo "Kansio $log puuttuu!"
    virheita+=1
fi

# 4

if ! poista-domain.sh "$domain"; then
    testi_echo "Domain ei löytynyt Linodesta!"
    virheita+=1
fi

#siivous

deluser --remove-home "$kayttaja"


exit "$virheita"
