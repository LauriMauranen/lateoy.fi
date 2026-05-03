#!/bin/bash

source avustajat.sh

kayttaja="matti"
home="/home/$kayttaja/"

if alusta-kayttaja.sh -s 2049; then
    testi_echo "alusta-kayttaja loi yli kahden gigan kotikansion!"
    virheita+=1
fi

if ! alusta-kayttaja.sh -s 1 "$kayttaja"; then
    testi_echo "alusta-kayttaja palautti virheen"
    virheita+=1
fi

koko="$(du -sh "$KOTIKANSIOT/$kayttaja")"

if [[ "${koko% *}" != "1M"  ]]; then
    testi_echo "Kotikansio on väärän kokoinen!"
    virheita+=1
fi
