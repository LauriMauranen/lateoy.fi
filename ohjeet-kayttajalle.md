# Tervetuloa lateoy.fi asiakkaaksi!

Olet käyttäjä {{ kayttaja }} ja sinulla on kotihakemistossasi /home/{{ kayttaja }} tilaa {{ koti-koko }} MB. Nettisivusi data-hakemisto löytyy /www-data/{{ kayttaja }}.{{ domain }} tai jos sinulla on oma domain niin /www-data/<oma-domain>. Huomaa että kaikki data-hakemiston tiedostot löytyvät https://{{ kayttaja }}.{{ domain }}/, joten varo laittamasta sinne tiedostoja joita et halua jakaa kaikille!

## Taustapalvelu

Jos haluat sivullesi dynaamista sisältöä, voit laittaa pyörimään sovelluksesi Podmanilla (https://podman.io). Podman on täysin Docker-yhteensopiva. Jokaiselle osoitteellesi on määritetty portti johon nginx ohjaa liikenteen jos polun tiedostoa ei löydy data-hakemistosta. Portit löydät tiedostosta ~/{{ portit }}. Laita konttisi siis kuuntelemaan oikeaa porttia.

Podman hoitaa kontin uudelleenkäynnistyksen hyödyntäen systemd:tä (https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html). **Eli kontti käynnistetään käyttäen komentoa systemctl, ei podman!** Luo tiedosto ~/{{ systemd-tiedosto }} jossa kontin käynnistysparametrit määritetään. Esimerkkitiedosto voisi olla

```
[Unit]
Description=Vinskis Great Button Game

[Container]
Image=localhost/vinskis-great-button-game_btn-game:latest
ContainerName=btn-game
Volume=/home/{{ kayttaja }}/log/{{ kayttaja }}.{{ domain }}/gunicorn:/usr/src/app/log/gunicorn
Volume=/home/{{ kayttaja }}/sqlite/button-game.db:/usr/src/app/button-game.db
PublishPort=8047:8047
Exec=-b 0.0.0.0:8047  # gunicorn kuuntelemaan porttia 8047

[Install]
WantedBy=default.target

[Service]
Restart=always
RestartSec=5
TimeoutStartSec=900
```

Kun olet tehnyt tiedostoon muutoksia laita uusi kontti ajoon komennoilla

```
# lataa uusi tiedosto
systemctl --user daemon-reload

# laita käyntiin, servicen nimi tulee ContainerName-kentästä
systemctl --user start nginx

# vaaditaan että kontti pysyy käynnissä uloskirjautumisen jälkeen
loginctl enable-linger

# aja restart kun haluat ottaa päivitetyn kontin kuvan käyttöön
systemctl --user restart nginx

podman ps
# CONTAINER ID  IMAGE                       COMMAND                CREATED           STATUS          PORTS                   NAMES
# f18118a16346  localhost/vinskis-great...  -b 0.0.0.0:8047  two seconds ago   Up two seconds  0.0.0.0:8047->8047/tcp  btn-game
```
