#!/bin/bash

set -euo pipefail

tee_koko_domain() {
    domain="$1"
    record="$2"

    if [[ "$record" == "$domain" ]]; then
	koko_domain="$domain"
    elif [[ "$record" =~ ^[a-zA-Z0-9_-]+$ ]]; then
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

hae_record_id_linodesta() {
    local record="$1"
    local domain="$2"
    local domain_id="$3"

    gr="\s$record\s"
    [[ "$domain" == "$record" ]] && gr="A\s*172"

    record_id=$(domains_komento records-list "$domain_id" | grep "$gr" || :)

    if [[ "$record_id" =~ [0-9]+ ]]; then
	echo "${BASH_REMATCH[0]}"
    else
	echo "Recordin $record hakeminen Linodelta epäonnistui"
	echo
	return 1
    fi
}


# testeihin


declare -i virheita=0

testi_echo() {
    >&2	echo "${0##*/}: $@"
}

siivoa_kayttaja_ja_domain() {
    set +e
    deluser --remove-home "$1"
    poista-domain.sh "$2"
}

alusta_kayttaja_ja_domain() {
    kayttaja="$1"
    domain="$2"
    if "$3"; then
	lisaa_record="-r"
    else
	lisaa_record=
    fi

    siivoa_kayttaja_ja_domain "$kayttaja" "$domain"

    set -e
    lisaa-kayttaja.sh "$kayttaja"
    lisaa-domain.sh $lisaa_record "$kayttaja" "$domain"
}

onhan_kansio_olemassa() {
    if [[ ! -e "$1" ]]; then
	testi_echo "Kansio $1 puuttuu!"
	virheita+=1
    fi
}

eihan_kansio_ole_olemassa() {
    if [[ -e "$1" ]]; then
	testi_echo "Kansio $1 on olemassa!"
	virheita+=1
    fi
}

satunnainen_mj() {
    local merkit=abcdefghijklmnopqrstuvwxyz
    local n="${#merkit}"
    local tulos=

    for i in {0..9}; do
	local idx="$((RANDOM % n))"
	local tulos+="${merkit:idx:1}"
    done

    echo "$tulos"
}
