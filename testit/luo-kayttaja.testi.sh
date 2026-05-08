#!/bin/bash

source avustajat.sh

kayttaja="matti"

if luo-kayttaja.sh -s 2049 "$kayttaja"; then
    testi_echo "luo-kayttaja loi yli kahden gigan kotikansion!"
    virheita+=1
fi

if ! luo-kayttaja.sh -s 10 "$kayttaja"; then
    testi_echo "luo-kayttaja palautti virheen"
    virheita+=1
fi

onhan_olemassa "/home/$kayttaja"
onhan_olemassa "$MOUNT_KANSIOT/home/$kayttaja"

# koko="$(du -sh "$MOUNT_KANSIOT/home/$kayttaja")"

# if [[ "${koko% *}" != "1M"  ]]; then
#     testi_echo "Kotikansio on väärän kokoinen! ($koko)"
#     virheita+=1
# fi


exit "$virheita"
