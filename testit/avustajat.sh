#!/bin/bash

set -euo pipefail

declare -i virheita=0

testi_echo() {
    echo "${0##*/}: $@" 
}

domains_komento() {
    podman compose run --rm -e LINODE_CLI_TOKEN="$LINODE_CLI_TOKEN" linode-cli \
	domains --text "$@"
}

poista_domain() {
    local domain="$1"

    local domain_id=$(domains_komento ls | grep "\s$domain\s" || :)

    if [[ $domain_id =~ [0-9]+ ]]; then
	domains_komento rm "${BASH_REMATCH[0]}"
    else
	echo "Domainin hakeminen Linodelta epäonnistui"
	exit 1
    fi
}
