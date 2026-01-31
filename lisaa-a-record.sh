#!/bin/bash

set -euo pipefail
shopt -s extglob

seuraavaPortti() {
    local tiedosto="$1"
    local portti=

    # luetaan ensimmäinen rivi
    while read -r rivi; do
      local portti="$rivi"
      break
    done <$tiedosto

    if [[ (( $portti > 7999 )) || (( $portti < 8999 )) ]]; then
	# poistetaan portti tiedostosta
	sed '1d' -i $tiedosto
    else
	echo "Portin pitää olla välillä 8000-8999! ($portti)"
	local portti=
    fi

    echo $portti
}

backend_portti=
while getopts "h" flag; do
    case "${flag}" in
        h) echo "Käyttö: lisaa-a-record kayttaja domain record" 
	   echo
	   echo "Lisää A-recordin domainille Linodeen ja tekee sille nginx-konfiguraation ja tarvittavat kansiot ja päivittää nginx-kontin."
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   exit 0
		;;
	# p) backend_portti="$OPTARG" 
		# ;;
    esac
done

kayttaja="$1"
domain="$2"
record="$3"

koko_domain=$record
[[ $domain != $record ]] && koko_domain="$record.$domain"

# kansiot

data="/www-data/$koko_domain"
log="/var/log/$domain/$koko_domain"

mkdir -p -v "$data" "$log/nginx"
echo "Terve $kayttaja!" > "$data/index.html"

chown "$kayttaja:$kayttaja" "$data" "$log" -R

# nginx-konfiguraatio

nginx_conf="/home/lauri/nginx/conf.d/$koko_domain.conf"
nginx_template=/home/lauri/lateoy.fi/conf.d/user-template
portit=/home/lauri/nginx/porttinumerot.txt

[[ -z $backend_portti ]] && backend_portti=$(seuraavaPortti $portit)
[[ -z $backend_portti ]] && exit 1

sed_1="s/{{ domain }}/$domain/g"
sed_2="s/{{ koko-domain }}/$koko_domain/g"
sed_3="s/{{ backend-port }}/$backend_portti/g"

sed -e "$sed_1" -e "$sed_2" -e "$sed_3" "$nginx_template" > "$nginx_conf"

chown lauri:lauri "$nginx_conf"

echo "Luotiin $nginx_conf"

# linode

cli_token=$(cat /home/lauri/.secrets/linode/cli.token)
ip=172.234.123.168 
email=lauri.mauranen@gmail.com

domain_id=$(podman compose run --rm -e LINODE_CLI_TOKEN=$cli_token linode-cli \
    domains ls | grep $domain)

if [[ $domain_id =~ [0-9]+ ]]; then
    domain_id="${BASH_REMATCH[0]}"
else
    echo "Domainin hakeminen Linodelta epäonnistui"
    exit 1
fi

podman compose run --rm -e LINODE_CLI_TOKEN=$cli_token linode-cli \
    domains records-create --name $record --type A --target $ip $domain_id

# päivitetään nginx

echo "Odotetaan 10 sekuntia..."
sleep 10

if podman exec nginx nginx -t; then
    podman exec nginx nginx -s reload
    echo "Ladattiin uusi nginx-konfiguraatio. https://$koko_domain toimii nyt."
else
    mv "$nginx_conf" "$nginx_conf.error"
    echo "Nginx-konfiguraatio palautti virheen! Löytyykö domainilta ssl-sertifikaatti?"
fi
