#!/bin/bash

set -euo pipefail

source avustajat.sh

# 1

set +e
if ./lisaa-kayttaja.sh; then
    testi_echo "lisaa-kayttaja.sh vaatii käyttäjän!"
    virheita+=1
fi
set -e


# siivous
poista_scriptit_testikansiosta
exit "$virheita"
