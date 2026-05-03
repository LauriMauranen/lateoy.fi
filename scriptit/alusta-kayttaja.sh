#!/bin/bash

source avustajat.sh

kotikansionKokoMB=1024

while getopts "hs:" flag; do
    case "${flag}" in
        h) echo "Käyttö: alusta-kayttaja.sh kayttaja" 
	   echo
	   echo "Luo käyttäjälle mountatun kotikansion."
	   echo
	   echo "  -s KOKO       Kotikansion koko (MB)."	
	   echo "  -h            Tulosta tämä viesti."	
	   exit 0
		;;
	s) kotikansionKokoMB="$OPTARG"
	    ;;

    esac
done

if ! tarkista_root; then exit 1; fi

kayttaja="${@:$OPTIND:1}"

if [[ "$kotikansionKokoMB" > 2048 ]]; then
    echo "Kotikansio voi olla max 2G"
    exit 1
fi

home="/home/$kayttaja"
MOUNT="$KOTIKANSIOT/$kayttaja"

mkdir -v "$home"

# luodaan tiedosto kotikansiolle ja mountataan se homeen
dd if=/dev/zero of="$MOUNT" bs=1M count="$kotikansionKokoMB"
mkfs.ext4 "$MOUNT"
mount "$MOUNT" "$home"

mkdir -v "$home/.ssh"
touch "$home/.ssh/authorized_keys"

chown "$kayttaja" "$home" -R
chmod 700 "$home"
