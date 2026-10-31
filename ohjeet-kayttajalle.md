## Tervetuloa lateoy.fi asiakkaaksi!

Olet käyttäjä {{ kayttaja }} ja sinulla on kotihakemistossa /home/{{ kayttaja }} tilaa {{ koti_koko }} MB. Nettisivusi data-hakemisto löytyy /www-data/{{ kayttaja }}.{{ domain }} tai jos olet ostanut oman domainin niin /www-data/<oma-domain>. Huomaa että kaikki data-hakemiston tiedostot löytyvät https://{{ kayttaja }}.{{ domain }}, joten varo laittamasta sinne tiedostoja joita et halua jakaa!

### Taustapalvelu

Jos haluat sivullesi dynaamista sisältöä, voit laittaa pyörimään sovelluksesi podmanilla (https://podman.io). Podman on täysin Docker-yhteensopiva. Laita kontti kuuntelemaan porttia {{ portti }} vivulla -p 172.234.123.168:{{ portti }}:{{ portti }}, nginx ohjaa liikenteen siihen jos polun tiedostoa ei löydy data-hakemistosta.
