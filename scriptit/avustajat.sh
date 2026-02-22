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
	echo "Record on epäkelpo!" >2&
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
	echo "Domainin $domain hakeminen Linodesta epäonnistui!" >2&
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
	echo "Recordin $record hakeminen Linodesta epäonnistui!" >2&
	return 1
    fi
}

poista_domain_linodesta() {
    local domain="$1"
    domain_id=$(hae_domain_id_linodesta "$domain" || :)
    [[ -z "$domain_id" ]] && return 0
    domains_komento rm "$domain_id"
    echo "Domain $domain poistettiin Linodesta"
}

seuraava_portti() {
    local tiedosto="$1"
    local portti=

    # luetaan ensimmäinen rivi
    while read -r rivi; do
      local portti="$rivi"
      break
    done <"$tiedosto"

    if [[ (( "$portti" > 7999 )) || (( "$portti" < 8999 )) ]]; then
	# poistetaan portti tiedostosta
	sed '1d' -i "$tiedosto"
    else
	echo "Portin pitää olla välillä 8000-8999! ($portti)" >2&
	local portti=
    fi

    echo $portti
}

laita_portti_takaisin() {
    local portit="$1"
    local nginx_conf="$2"
    local record=${nginx_conf##*/}
    local record=${record%.*}

    local portti=$(grep "proxy_pass http://$record:\d\d\d\d;" $nginx_conf || :)
    local portti=${portti##*:}
    local portti=${portti%;}

    if [[ -z $portti ]]; then
	echo "Portti on tyhjä merkkijono!" >2&
    else 
	echo "$portti" >> $portit
    fi
}

rakenna_nginx_conf() {
    local domain="$1"
    local koko_domain="$2"
    local backend_port="$3"
    local nginx_template="$4"

    local sed_1="s/{{ domain }}/$domain/g"
    local sed_2="s/{{ koko-domain }}/$koko_domain/g"
    local sed_3="s/{{ backend-port }}/$backend_portti/g"

    sed -e "$sed_1" -e "$sed_2" -e "$sed_3" "$nginx_template"
}


# testeihin


declare -i virheita=0

testi_echo() {
    echo "${0##*/}: $@" >&2	
}

poista_kayttaja_ja_domain() {
    set +e
    deluser --remove-home "$1"
    set -e
    poista_domain_linodesta "$2"
}

alusta_kayttaja_ja_domain() {
    kayttaja="$1"
    domain="$2"
    if "$3"; then
	lisaa_record="-r"
    else
	lisaa_record=
    fi

    lisaa-kayttaja.sh "$kayttaja"
    lisaa-domain.sh $lisaa_record "$kayttaja" "$domain"
}

onhan_olemassa() {
    if [[ ! -e "$1" ]]; then
	testi_echo "Kansio $1 puuttuu!"
	virheita+=1
    fi
}

eihan_ole_olemassa() {
    if [[ -e "$1" ]]; then
	testi_echo "Kansio $1 on olemassa!"
	virheita+=1
    fi
}

satunnainen_mj() {
    local merkit=abcdefghijklmnopqrstuvwxyz
    local n="${#merkit}"
    local tulos=

    for i in {0..15}; do
	local idx="$((RANDOM % n))"
	local tulos+="${merkit:idx:1}"
    done

    echo "$tulos"
}
