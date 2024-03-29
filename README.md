# rpi-vieraskirja

<img src="https://kaatis.party/Captive.gif" height="300" align="right">

Avoimeen WiFi-verkkoon liittymisestä itsestään avautuva vieraskirja. 🚓✍️

Suunniteltu Raspberry Pi:lle helpolla käyttöönotolla käyttäen Dockeria. Muodostaa avoimen WiFi-tukiaseman ja hyödyntää käyttöjärjestelmien Captive portal -ominaisuutta.

## Ohjeet

Ohjeet kokeiltu Raspberry Pi Zerolla, jolla Raspberry Pi OS (Debian) -käyttöjärjestelmä.

Sinulla tulee olla Docker asennettuna. Voit asentaa sen helposti skriptillä: https://docs.docker.com/engine/install/debian/#install-using-the-convenience-script. 

Varmista, että WiFi-sovittimesi tukee AP tilaa:

```
# iw list
...
        Supported interface modes:
                 * IBSS
                 * managed
                 * AP
                 * AP/VLAN
                 * WDS
                 * monitor
                 * mesh point
...
```

Aja seuraavat komennot:

```
# iw reg set FI
```

```
# git clone https://github.com/testausserveri/rpi-vieraskirja
# cd rpi-vieraskirja
# docker compose build
# docker compose up
```

Jälkiviisautena, voit vaihtaa tukiaseman SSID:tä tai verkkosovitinta docker-compose.yml:ssä.