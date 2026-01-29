#!/bin/bash

set -euo pipefail
shopt -s extglob

while getopts "hr" flag; do
    case "${flag}" in
        h) echo "Käyttö: lisaa-domain kayttaja domain" 
	   echo
	   echo "Lisää käyttäjälle domainin ja sille tarvittavat kansiot."
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   echo "  -r            Luo domainille myös A/AAAA record."	
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
    domains create --name $domain --type master --soa_email $email
