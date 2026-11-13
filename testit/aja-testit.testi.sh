#!/bin/bash

source avustajat.sh
set +e

# 1

teksti="Ajetaan testit testi-lapi.testix.sh testi-virhe.testix.sh"

if [[ ! "$(aja-testit.sh *.testix.sh)" =~ "$teksti" ]]; then
    testi_echo "aja-testi.sh ajoi väärät testit!"
fi

teksti="Ajetaan testit testi-lapi.testix.sh"

if [[ ! "$(aja-testit.sh testi-lapi.testix.sh)" =~ "$teksti" ]]; then
    testi_echo "aja-testi.sh ajoi väärät testit!"
fi

# 2

if ! aja-testit.sh testi-lapi*; then
    testi_echo "testi-lapi.testix.sh palautti virheen!"
fi

teksti="testi-lapi.testix.sh teksti"

if [[ ! "$(aja-testit.sh -v testi-lapi*)" =~ "$teksti" ]]; then
    testi_echo "testi-lapi.testix.sh verboosina ei anna oikeaa outputtia!"
fi

teksti="Läpi | testi-lapi.testix.sh"

if [[ ! "$(aja-testit.sh testi-lapi*)" =~ "$teksti" ]]; then
    testi_echo "testi-lapi.testix.sh tulos output on väärä!"
fi

# 3

if aja-testit.sh testi-virhe*; then
    testi_echo "testi-virhe.testix.sh ei palauttanut virhettä!"
fi

teksti="testi-virhe.testix.sh teksti"

if [[ ! "$(aja-testit.sh -v testi-virhe*)" =~ "$teksti" ]]; then
    testi_echo "testi-virhe.testix.sh verboosina ei anna oikeaa outputtia!"
fi

teksti="Virheitä 1 | testi-virhe.testix.sh"

if [[ ! "$(aja-testit.sh testi-virhe*)" =~ "$teksti" ]]; then
    testi_echo "testi-virhe.testix.sh tulos output on väärä!"
fi


exit "$virheita"
