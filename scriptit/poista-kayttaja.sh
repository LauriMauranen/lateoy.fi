#!/bin/bash

source avustajat.sh

while getopts "h" flag; do
    case "${flag}" in
        h) alkuotsikko "kayttaja" 
	   echo
	   echo "Poistaa käyttäjän ja käyttäjän kansiot. HUOM! Ei poista käyttäjän a-recordeja."
	   echo
	   echo "  -h            Tulosta tämä viesti."	
	   exit 0
		;;
    esac
done

if ! tarkista_root; then exit 1; fi

kayttaja="${@:$OPTIND:1}"

if ! grep "$kayttaja:" /etc/passwd; then
    virhe "$kayttaja ei ole olemassa!"
fi

home="/home/$kayttaja"

umount "$home"

rm -rf "$MOUNT_KANSIOT/$home" "$home"

userdel "$kayttaja"
