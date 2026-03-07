#!/bin/bash

set -euo pipefail

LOKIT=/var/log/sovelluslokit
PORTIT=/home/lauri/nginx/porttinumerot.txt
NGINX_CONFD=/home/lauri/nginx/conf.d

tee_koko_domain() {
    domain="$1"
    record="$2"

    if [[ "$record" == "$domain" ]]; then
	koko_domain="$domain"
    elif [[ "$record" =~ ^[a-zA-Z0-9_-]+$ ]]; then
	koko_domain="$record.$domain"
    else
	echo "Record on epäkelpo!" >&2
	return 1
    fi

    echo "$koko_domain"
}

ota_portti_tiedostosta() {
    local tiedosto="$1"
    local porttitoive="$2"

    declare -i local nro=1
    local portti=

    if [[ ! -z "$porttitoive" ]]; then
	while read -r rivi; do
	    if [[ "$rivi" == "$porttitoive" ]]; then
	      local portti="$rivi"
	      break
	    fi
	    local nro+=1 
	done <"$tiedosto"
    fi

    if [[ -z "$portti" ]]; then
	local nro=1
	while read -r rivi; do
	  local portti="$rivi"
	  break
	done <"$tiedosto"
    fi

    # poistetaan portti tiedostosta
    sed "${nro}d" -i "$tiedosto"

    echo $portti
}

laita_portti_takaisin() {
    nginx_conf="$1"
    koko_domain="$2"

    local portti="$(grep -P "proxy_pass http://$koko_domain:\d{4};" "$nginx_conf" || :)"
    local portti="${portti##*:}"
    local portti="${portti%;}"

    if [[ -z "$portti" ]]; then
	echo "Portin etsiminen tiedostosta $nginx_conf epäonnistui!" >&2
    else 
	echo "$portti"
    fi
}

rakenna_nginx_conf() {
    local domain="$1"
    local koko_domain="$2"
    local backend_portti="$3"
    local nginx_template="$4"

    local lokit="$LOKIT/$domain/$koko_domain/nginx"

    local sed_1="s/{{ domain }}/$domain/g"
    local sed_2="s/{{ koko-domain }}/$koko_domain/g"
    local sed_3="s/{{ backend-port }}/$backend_portti/g"
    local sed_4="s/{{ lokit }}/${lokit//\//\\/}/g"

    sed -e "$sed_1" -e "$sed_2" -e "$sed_3" -e "$sed_4" "$nginx_template"
}


# testeihin


declare -i virheita=0

testi_echo() {
    echo "${0##*/}: $@" >&2	
}

onhan_olemassa() {
    if [[ ! -e "$1" ]]; then
	testi_echo "Kansio/tiedosto $1 puuttuu!"
	virheita+=1
    fi
}

eihan_ole_olemassa() {
    if [[ -e "$1" ]]; then
	testi_echo "Kansio/tiedosto $1 on olemassa!"
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
