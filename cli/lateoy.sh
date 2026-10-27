#!/bin/bash

set -euo pipefail

SERVERI=lateoy.fi
SELITE=selite
HELP=help
KOMENTO=komento
declare -i INFOPARI_N_VALIA=14

declare -A k_selitteet
declare -A helpit
declare -A a_selitteet

komennot=("konsoli")
asetukset=("h")

k_selitteet_lista=(
    "Avaa konsoli serverille"
)

helpit_lista=(
    "konsoli help"
)

a_selitteet_lista=(
    "Näytä tämä sivu"
)

for i in "${!komennot[@]}"; do
    k_selitteet["${komennot[$i]}"]="${k_selitteet_lista[$i]}"
    helpit["${komennot[$i]}"]="${helpit_lista[$i]}"
done

for i in "${!asetukset[@]}"; do
    a_selitteet["${asetukset[$i]}"]="${a_selitteet_lista[$i]}"
done

virhe() {
    echo
    echo "lateoy-cli virhe: $1"
    exit 1
}

infopari() {
    echo -n "  $1"
    for ((i = 0; i < "$INFOPARI_N_VALIA" - 2 - "${#1}"; i++)); do
	echo -n " "
    done	
    echo "$2"
}

_help() {
  echo "Hallitse resursseja serverillä lateoy.fi" 
  echo
  echo "Käyttö: lateoy.sh [asetukset] [komento]" 
  echo
  echo "Mahdolliset komennot:"
  for k in "${komennot[@]}"; do infopari "$k" "${k_selitteet[$k]}"; done
  echo
  echo "Mahdolliset asetukset:"
  for a in "${asetukset[@]}"; do infopari "-$a" "${a_selitteet[$a]}"; done
}

k_konsoli() {
    # ssh "$SERVERI"
    echo "konsoli"
}

[[ "$#" -eq 0 ]] && _help && exit 0

tuli_help=0
metodi="$KOMENTO"

while getopts "h" flag; do
    case "${flag}" in
	h) 
	    tuli_help=1
	    ;;
    esac
done

metodi="$tuli_help"
komento="${@:$OPTIND:1}" 

[[ -z "$komento" ]] && _help && exit 0

for k in "${komennot[@]}"; do
    if [[ "$k" == "$komento" ]]; then
	[[ "$tuli_help" -eq 1 ]] && echo "${helpit[$k]}" && exit 0
	eval "k_$komento" && exit 0
    fi
done

_help
virhe "Tuntematon komento '$komento'"
