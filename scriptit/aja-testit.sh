#!/bin/bash

set -uo pipefail

declare -A tulokset

aja_testi() {
    local testi="$1"

    v=
    if ! "$verboosi"; then
	v="&> /dev/null"
    fi

    eval "./$testi $v"
    echo "TESTITULOS $testi $?"
}

verboosi=false

while getopts "hv" flag; do
    case "${flag}" in
        h) echo "Käyttö: aja-testit [asetukset] testi..." 
	   echo
	   echo "Ajaa testit."
	   echo
	   echo "  -v            Verboosi."	
	   echo "  -h            Tulosta tämä viesti."	
	   exit 0
		;;
	v) verboosi=true
		;;
    esac
done

testit="${@:OPTIND:${#@}}"
kansio=/sovellus/testit

if [[ -z "$testit" ]]; then
    testit=*testi.sh
else
    uusi_testit=
    for testi in "$testit"; do
	uusi_testit+="${testi##*/}"
    done
    testit="$uusi_testit"
fi

cd "$kansio"

while read -r tulos; do
    [[ "$tulos" =~ TESTITULOS ]] || continue
    testi="${tulos% *}"
    testi="${testi#* }"
    virheita="${tulos##* }"
    tulokset["$testi"]="$virheita"
done < <(for t in $testit; do aja_testi "$t" & done)

palautus=0

for testi in "${!tulokset[@]}"; do
    tulos=Läpi
    n="${tulokset[$testi]}"
    [[ "$n" > 0 ]] && tulos="Virheitä $n" && palautus=1
    echo "$tulos | $testi"
done

exit "$palautus"
