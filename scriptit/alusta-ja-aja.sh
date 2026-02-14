#!/bin/sh

apk update
apk add bash py3-pip

pip3 install podman-compose --break-system-packages --root-user-action ignore

cd /sovellus/scriptit
PATH=$PATH:/sovellus/scriptit bash aja-testit.sh
