#!/bin/bash

source /sovellus/scriptit/avustajat.sh
set +e

kayttaja=matti
domain=masa.com

# siivous

deluser --remove-home "$kayttaja"
poista-domain.sh "$domain"

# 1

if ! (lisaa-kayttaja.sh "$kayttaja" && lisaa-domain.sh "$kayttaja" "$domain"); 
then
    testi_echo "Joko käyttäjän tai domainin lisääminen epäonnistui!"
    virheita+=1
fi

# 2

log="/var/log/$domain"

if [[ ! -e "$log" ]]; then
    testi_echo "Kansio $log puuttuu!"
    virheita+=1
fi

# 3

if ! poista-domain.sh "$domain"; then
    testi_echo "Domain ei löytynyt Linodesta!"
    virheita+=1
fi


exit "$virheita"
