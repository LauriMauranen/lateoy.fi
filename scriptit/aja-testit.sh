#!/bin/bash

set -uo pipefail

while getopts "h" flag; do
    case "${flag}" in
        h) echo "Käyttö: aja-testit testi..." 
	   echo
	   echo "Ajaa testit."
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   exit 0
		;;
    esac
done

testit="$@"
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

declare -A tulokset
declare -i palautus

cd "$kansio"

for testi in $testit; do
    echo "Ajetaan $testi"
    echo
    ./"$testi"
    tulokset["$testi"]="$?"
    palautus+="$?"
done

echo

for testi in "${!tulokset[@]}"; do
    tulos=Läpi
    n="${tulokset[$testi]}" 
    [[ "$n" > 0 ]] && tulos="Virheitä $n"
    echo "$tulos | $testi"
done

exit "$palautus"
