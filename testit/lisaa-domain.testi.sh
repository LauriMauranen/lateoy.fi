#!/bin/bash

set -euo pipefail

source avustajat.sh

# 1

set +e
if lisaa-domain.sh; then
    set -e
    testi_echo "lisaa-domain.sh vaatii käyttäjän ja domainin!"
    virheita+=1
fi


exit "$virheita"
