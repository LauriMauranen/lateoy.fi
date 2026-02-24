#!/bin/bash

testiajo=false 
[[ "$TESTIAJO" == true ]] && testiajo=true

set -uo pipefail

declare -A tulokset

aja_testi() {
    local testi="$1"
    local kansio="$2"

    ./"$testi" &> "$kansio/${testi%.sh}"
    echo "$testi $?"
}
export -f aja_testi

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

stdout_kansio=/tmp/testitmp/aja-testit-stdout
testikansio=/sovellus/testit

if ! "$testiajo"; then
    mkdir -p "$stdout_kansio"
fi

if [[ -z "$testit" ]]; then
    testit=*.testi.sh
else
    uusi_testit=
    for testi in "$testit"; do
	uusi_testit+="${testi##*/}"
    done
    testit="$uusi_testit"
fi

export TESTIAJO=true
cd "$testikansio"
echo "Ajetaan testit $(echo $testit)"

while read -r tulos; do
    testi="${tulos% *}"
    virheita="${tulos#* }"
    tulokset["$testi"]="$virheita"
done < <(parallel aja_testi ::: $testit ::: "$stdout_kansio")

palautus=0

if "$verboosi"; then
    for testi in $testit; do
	echo "$testi output:"
	echo
	cat "$stdout_kansio/${testi%.sh}"
	echo
    done
fi

for testi in "${!tulokset[@]}"; do
    tulos=Läpi
    n="${tulokset[$testi]}"
    [[ "$n" > 0 ]] && tulos="Virheitä $n" && palautus=1
    echo "$tulos | $testi"
done

if ! "$testiajo"; then
    rm -r "$stdout_kansio"
    unset TESTIAJO
fi

exit "$palautus"
