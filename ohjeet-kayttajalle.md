## Tervetuloa lateoy.fi asiakkaaksi!

Olet käyttäjä {{ kayttaja }} ja sinulla on kotihakemistossa /home/{{ kayttaja }} tilaa {{ koti_koko }} MB. Nettisivusi data-hakemisto löytyy /www-data/{{ kayttaja }}.{{ domain }} tai jos olet ostanut oman domainin niin /www-data/<oma-domain>. Huomaa että kaikki data-hakemiston tiedostot löytyvät https://{{ kayttaja }}.{{ domain }}, joten varo laittamasta sinne tiedostoja joita et halua jakaa!

### Taustapalvelu

Jos haluat sivullesi dynaamista sisältöä, voit laittaa pyörimään sovelluksesi podmanilla (https://podman.io). Podman on täysin Docker-yhteensopiva. Laita kontti kuuntelemaan porttia {{ portti }} vivulla -p 172.234.123.168:{{ portti }}:{{ portti }}, nginx ohjaa liikenteen siihen jos polun tiedostoa ei löydy data-hakemistosta.

#### Kontin uudelleenkäynnistys

Podman hoitaa kontin uudelleenkäynnistyksen hyödyntäen systemd (https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html). Luo tiedosto $HOME/.config/containers/systemd/<sovellus>.container jossa kontin käynnistysparametrit määritetään, samalla idealla kuin compose.yaml. Esimerkkitiedosto voisi olla

```
[Unit]
Description=Laurin mahtava systeemi

[Container]
Image=docker.io/nginx:1.29.4-alpine
ContainerName=nginx
PublishPort=80:80
PublishPort=443:443
Volume=/etc/letsencrypt:/etc/letsencrypt:ro
Volume=/home/lauri/lateoy.fi/nginx.conf:/etc/nginx/nginx.conf:ro
Volume=/home/lauri/nginx/conf.d:/etc/nginx/conf.d:ro
Volume=/var/log:/var/log
Volume=/www-data:/www-data:ro

[Install]
WantedBy=default.target

[Service]
Restart=always
RestartSec=5
TimeoutStartSec=900
```

Kun tiedosto löytyy oikeasta paikasta saat kontin käyntiin komennoilla

```
# lataa uusi tiedosto
systemctl --user daemon-reload
# laita käyntiin
systemctl --user start nginx
```

servicen nimi tulee ContainerName kentästä.
