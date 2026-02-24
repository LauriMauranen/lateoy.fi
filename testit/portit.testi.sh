#!/bin/bash

source /sovellus/scriptit/avustajat.sh

portti_echo() {
    testi_echo "piti olla portti '$1', olikin '$2'"
}

# alustus

tiedosto=/tmp/testitmp/porttinumerot.txt
for i in {8000..8999}; do echo "$i" >> "$tiedosto"; done

set +e

# 1

p="$(ota_portti_tiedostosta "$tiedosto" "")"
if [[ "$p" != 8000 ]]; then
    portti_echo 8000 "$p"
    virheita+=1
fi

p="$(ota_portti_tiedostosta "$tiedosto" 8000)"
if [[ "$p" != 8001 ]]; then
    portti_echo 8001 "$p"
    virheita+=1
fi

ota_portti_tiedostosta "$tiedosto" 7999  # 8002
ota_portti_tiedostosta "$tiedosto" "jaajaa"  # 8003

p="$(ota_portti_tiedostosta "$tiedosto" 8999)"
if [[ "$p" != 8999 ]]; then
    portti_echo 8999 "$p"
    virheita+=1
fi

p="$(ota_portti_tiedostosta "$tiedosto" "")"
if [[ "$p" != 8004 ]]; then
    portti_echo 8999 "$p"
    virheita+=1
fi

# siivous

rm "$tiedosto"


exit "$virheita"
