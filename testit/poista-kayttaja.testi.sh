#!/bin/bash

source avustajat.sh

kayttaja="mattimattimatti"
home="/home/$kayttaja"

luo-kayttaja.sh -s 10 "$kayttaja"

if ! poista-kayttaja.sh "$kayttaja"; then
    testi_echo "poista-kayttaja palautti virheen"
fi

eihan_ole_olemassa "$home"
eihan_ole_olemassa "$MOUNT_KANSIOT$home"

if grep "$kayttaja:" /etc/passwd; then
    testi_echo "$kayttaja on vielä olemassa!"
fi


exit "$virheita"
