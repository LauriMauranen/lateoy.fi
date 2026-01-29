#!/bin/bash

set -euo pipefail
shopt -s extglob

record=0

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
	r) record=1
	   exit 0
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

podman compose run --rm -e LINODE_CLI_TOKEN=$cli_token linode-cli \
    domains create --domain $domain --type master --soa_email $email

[[ $record == 1 ]] && lisaa-alidomain $kayttaja $domain $domain
