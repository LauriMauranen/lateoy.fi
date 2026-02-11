#!/bin/bash

set -euo pipefail

SCRIPTIT=("lisaa-kayttaja.sh" "lisaa-domain.sh" "lisaa-a-record.sh" \
    "poista-domain.sh" "poista-a-record.sh")

for s in "${SCRIPTIT[@]}"; do
    cp "../$s" .
done

declare -i virheita

poista_scriptit_testikansiosta() {
    rm "${SCRIPTIT[@]}"
}

testi_echo() {
    echo "${0##*/}: $@" 
}
