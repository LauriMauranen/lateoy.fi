#!/bin/bash

source avustajat.sh

portti_echo() {
    testi_echo "piti olla portti '$1', olikin '$2'"
}

# alustus

tiedosto=/tmp/testitmp/porttinumerot.txt
for i in {8000..8999}; do echo "$i" >> "$tiedosto"; done

set +e


# ota_portti_tiedostosta

p="$(ota_portti_tiedostosta "$tiedosto" "")"
if [[ "$p" != 8000 ]]; then
    portti_echo 8000 "$p"
fi

p="$(ota_portti_tiedostosta "$tiedosto" 8000)"
if [[ "$p" != 8001 ]]; then
    portti_echo 8001 "$p"
fi

ota_portti_tiedostosta "$tiedosto" 7999  # 8002
ota_portti_tiedostosta "$tiedosto" "jaajaa"  # 8003

p="$(ota_portti_tiedostosta "$tiedosto" 8999)"
if [[ "$p" != 8999 ]]; then
    portti_echo 8999 "$p"
fi

p="$(ota_portti_tiedostosta "$tiedosto" "")"
if [[ "$p" != 8004 ]]; then
    portti_echo 8999 "$p"
fi


# lue_portti

conf=/tmp/testitmp/nginx_conf
rakenna_nginx_conf 1 1 1234 "lokit" > "$conf"

p="$(lue_portti "$conf")"
if [[ "$p" != 1234 ]]; then
    portti_echo 1234 "$p"
fi


# poista_porttirivi_tai_koko_tiedosto

ojp=/tmp/testitmp/osoitteet-ja-portit.txt
s=$'jaa.com 123\njee.org 321' 
echo "${s}" > "$ojp"

poista_porttirivi_tai_koko_tiedosto "$ojp" 4321
o="$(cat "$ojp")"
if [[ "$s" != "${o}" ]]; then
    testi_echo "poista_porttirivi_tai_koko_tiedosto toimii väärin"
fi

poista_porttirivi_tai_koko_tiedosto "$ojp" 321
o="$(cat "$ojp")"
if [[ "$o" != "jaa.com 123" ]]; then
    testi_echo "poista_porttirivi_tai_koko_tiedosto ei poistanut riviä"
fi

poista_porttirivi_tai_koko_tiedosto "$ojp" 4321
if [[ -e "$ojp" ]]; then
    testi_echo "poista_porttirivi_tai_koko_tiedosto ei poistanut tiedostoa"
fi


# siivous

rm "$tiedosto"
rm "$conf"
rm -f "$ojp"


exit "$virheita"
