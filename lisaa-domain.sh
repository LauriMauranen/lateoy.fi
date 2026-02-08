#!/bin/bash

set -euo pipefail

domains_komento() {
    podman compose run --rm -e LINODE_CLI_TOKEN=$cli_token linode-cli domains \
	--text "$@"
}

record=false

while getopts "hr" flag; do
    case "${flag}" in
        h) echo "Käyttö: lisaa-domain kayttaja domain" 
	   echo
	   echo "Lisää käyttäjälle domainin Linodeen ja lokitus-kansion."
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   echo "  -r            Luo domainille myös A/AAAA record."	
	   exit 0
		;;
	r) record=true
		;;
    esac
done

kayttaja="$1"
domain="$2"

log="/var/log/$domain"

mkdir -p -v "$log"
chown "$kayttaja:$kayttaja" "$log" -R

cli_token=$(cat /home/lauri/.secrets/linode/cli.token)
email=lauri.mauranen@gmail.com

domains_komento create --domain $domain --type master --soa_email $email

if "$record"; then lisaa-alidomain $kayttaja $domain $domain; fi
