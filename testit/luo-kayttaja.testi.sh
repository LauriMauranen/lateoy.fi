#!/bin/bash

source avustajat.sh

kayttaja="matti"
home="/home/$kayttaja"

if luo-kayttaja.sh -s "$MAX_KOTI_KOKO"+1  "$kayttaja"; then
    testi_echo "luo-kayttaja.sh loi yli $MAX_KOTI_KOKO MB, kotikansion!"
fi

if ! luo-kayttaja.sh -s 10 "$kayttaja"; then
    testi_echo "luo-kayttaja.sh palautti virheen"
fi

onhan_olemassa "$home"
onhan_olemassa "$MOUNT_KANSIOT/$home"

if grep "{{" "$home/$KAYTTOOHJE"; then
    testi_echo "Käyttöohjeeseen on jäänyt muuttuja!"
    cat "$home/$KAYTTOOHJE"
fi


exit "$virheita"
