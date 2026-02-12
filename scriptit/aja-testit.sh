#!/bin/bash

set -euo pipefail

declare -A tulokset

declare -i palautus

cd testit

for testi in ./*testi.sh; do
    set +e
    ./"$testi"
    tulokset["$testi"]="$?"
    palautus+="$?"
done

echo

for testi in "${!tulokset[@]}"; do
    tulos=Läpi
    [[ "${tulokset[$testi]}" != 0 ]] && tulos=Virhe
    echo "$tulos | $testi"
done

exit "$palautus"
