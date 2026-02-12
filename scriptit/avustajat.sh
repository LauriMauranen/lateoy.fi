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

hae_domain_id() {
    local domain="$1"

    local domain_id=$(domains_komento ls | grep "\s$domain\s" || :)

    if [[ $domain_id =~ [0-9]+ ]]; then
	echo "${BASH_REMATCH[0]}"
    else
	echo "Domainin $domain hakeminen Linodelta epäonnistui!"
	return 1
    fi
}

poista_domain() {
    local domain="$1"

    local domain_id=$(hae_domain_id "$domain" || :)

    if [[ ! -z $domain_id ]]; then
	domains_komento rm "$domain_id"
    else
	echo "Domainin $domain poistaminen epäonnistui!"
	return 1
    fi
}
