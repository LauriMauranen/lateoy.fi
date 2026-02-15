#!/bin/bash

set -euo pipefail

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

export LINODE_CLI_TOKEN=$(cat /run/secrets/linode_cli_token)
declare -A tulokset
declare -i palautus

cd "$kansio"

for testi in $testit; do
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
