#!/bin/bash

source avustajat.sh

kayttaja="matti"
home="/home/$kayttaja"

if luo-kayttaja.sh -s 2049 "$kayttaja"; then
    testi_echo "luo-kayttaja loi yli kahden gigan kotikansion!"
fi

if ! luo-kayttaja.sh -s 10 "$kayttaja"; then
    testi_echo "luo-kayttaja palautti virheen"
fi

onhan_olemassa "$home"
onhan_olemassa "$MOUNT_KANSIOT/$home"

if grep "{{" "$home/$KAYTTOOHJE"; then
    testi_echo "Käyttöohjeeseen on jäänyt muuttuja!"
    cat "$home/$KAYTTOOHJE"
fi


exit "$virheita"
