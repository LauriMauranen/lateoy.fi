#!/bin/bash

source /sovellus/scriptit/avustajat.sh
set +e

# 1

teksti="Ajetaan testit testi-lapi.testix.sh testi-virhe.testix.sh"

if [[ ! "$(aja-testit.sh -t *.testix.sh)" =~ "$teksti" ]]; then
    testi_echo "aja-testi.sh ajoi väärät testit!"
    virheita+=1
fi

teksti="Ajetaan testit testi-lapi.testix.sh"

if [[ ! "$(aja-testit.sh -t testi-lapi.testix.sh)" =~ "$teksti" ]]; then
    testi_echo "aja-testi.sh ajoi väärät testit!"
    virheita+=1
fi

# 2

if ! aja-testit.sh -t testi-lapi*; then
    testi_echo "testi-lapi.testi.sh palautti virheen!"
    virheita+=1
fi

teksti="testi-lapi.testix.sh teksti"

if [[ ! "$(aja-testit.sh -t -v testi-lapi*)" =~ "$teksti" ]]; then
    testi_echo "testi-lapi.testi.sh verboosina ei anna oikeaa outputtia!"
    virheita+=1
fi

teksti="Läpi | testi-lapi.testix.sh"

if [[ ! "$(aja-testit.sh -t testi-lapi*)" =~ "$teksti" ]]; then
    testi_echo "testi-lapi.testi.sh tulos output on väärä!"
    virheita+=1
fi

# 3

if aja-testit.sh -t testi-virhe*; then
    testi_echo "testi-lapi.testi.sh ei palauttanut virhettä!"
    virheita+=1
fi

teksti="testi-virhe.testix.sh teksti"

if [[ ! "$(aja-testit.sh -t -v testi-virhe*)" =~ "$teksti" ]]; then
    testi_echo "testi-virhe.testi.sh verboosina ei anna oikeaa outputtia!"
    virheita+=1
fi

teksti="Virheitä 1 | testi-virhe.testix.sh"

if [[ ! "$(aja-testit.sh -t testi-virhe*)" =~ "$teksti" ]]; then
    testi_echo "testi-lapi.testi.sh tulos output on väärä!"
    virheita+=1
fi


exit "$virheita"
