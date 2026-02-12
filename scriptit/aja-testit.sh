#!/bin/bash

set -euo pipefail

declare -A tulokset
declare -i palautus

cd ../testit

set +e
for testi in ./*testi.sh; do
    ./"$testi"
    tulokset["$testi"]="$?"
    palautus+="$?"
done
set -e

echo

for testi in "${!tulokset[@]}"; do
    tulos=Läpi
    [[ "${tulokset[$testi]}" != 0 ]] && tulos=Virhe
    echo "$tulos | $testi"
done

exit "$palautus"
