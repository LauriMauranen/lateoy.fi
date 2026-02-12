#!/bin/sh

apk update
apk add bash

cd /sovellus/scriptit
PATH=$PATH:/sovellus/scriptit bash aja-testit.sh
