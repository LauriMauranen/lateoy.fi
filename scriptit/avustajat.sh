#!/bin/bash

set -euo pipefail

declare -i virheita=0

testi_echo() {
    echo "${0##*/}: $@" 
}

tee_koko_domain() {
    domain="$1"
    record="$2"

    if [[ "$record" == "$domain" ]]; then
	koko_domain="$domain"
    elif [[ "$domain" =~ ^[a-zA-Z0-9_-]+$ ]]; then
	koko_domain="$record.$domain"
    else
	echo "Record on epäkelpo!"
	return 1
    fi

    echo "$koko_domain"
}

domains_komento() {
    podman compose -f "$COMPOSE_LINODE" run --rm linode-cli domains --text "$@"
}

hae_domain_id_linodesta() {
    local domain="$1"

    local domain_id=$(domains_komento ls | grep "\s$domain\s" || :)

    if [[ "$domain_id" =~ [0-9]+ ]]; then
	echo "${BASH_REMATCH[0]}"
    else
	echo "Domainin $domain hakeminen Linodelta epäonnistui!"
	echo
	return 1
    fi
}

poista_domain_linodesta() {
    local domain="$1"

    local domain_id=$(hae_domain_id_linodesta "$domain")
    echo "hei"

    [[ ! -z "$domain_id" ]] && domains_komento rm "$domain_id"
}

poista_a_record_linodesta() {
    local domain="$1"
    local record="$2"

    local domain_id=$(hae_domain_id_linodesta "$domain")

    [[ ! -z "$domain_id" ]] && domains_komento rm "$domain_id"
}
