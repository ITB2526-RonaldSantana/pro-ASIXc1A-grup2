# Servei d'Àudio en Streaming — Icecast2 + FFmpeg

**Projecte Transversal ASIXc1 · Bloc 2 — RA7**  

---

## 1. Descripció del servei

El servei d'àudio en streaming permet distribuir contingut musical en continu a múltiples clients simultàniament. InnovateTech l'utilitza per a la comunicació interna i la formació corporativa.

**Icecast2** actua com a servidor que rep el flux d'àudio i el redistribueix a tots els clients connectats. **FFmpeg** llegeix els fitxers MP3 del servidor i els envia en continu cap a Icecast2.

**Flux de dades:**
```
Fitxers MP3 => FFmpeg (emissor) => Icecast2 (port 8000) => Clients
```

| Paràmetre | Valor |
|-----------|-------|
| Servidor | SRV-Audio-Video |
| IP pública | `23.23.53.151` |
| Port | 8000 TCP |
| Format àudio | MP3 128 kbps |
| URL del stream | `http://23.23.53.151:8000/radio.mp3` |
| Sistema operatiu | Ubuntu Server 26.04 |

---

## 2. Instal·lació

### Pas 1 — Actualitzar el sistema

sudo apt update 


### Pas 2 — Instal·lar Icecast2 i FFmpeg

sudo apt install icecast2 ffmpeg -y


Durant la instal·lació d'Icecast2 apareix un assistent que demana:

| Camp | Valor introduït |
|------|----------------|
| Hostname | `23.23.53.151` |
| Source password | `123` |
| Relay password | `123` |
| Admin password | `123` |

---

## 3. Configuració d'Icecast2

### Pas 3 — Editar el fitxer de configuració
```bash
sudo nano /etc/icecast2/icecast.xml
```

Paràmetres configurats:

```xml
<!-- Contrasenyes d'accés -->
<authentication>
    <source-password>123</source-password>
    <relay-password>123</relay-password>
    <admin-user>admin</admin-user>
    <admin-password>123</admin-password>
</authentication>

<!-- IP pública del servidor -->
<hostname>23.23.53.151</hostname>

<!-- Port d'escolta -->
<listen-socket>
    <port>8000</port>
</listen-socket>

<!-- Límit de clients simultanis -->
<limits>
    <clients>100</clients>
    <sources>10</sources>
    <client-timeout>30</client-timeout>
</limits>

<!-- Ubicació dels logs -->
<logging>
    <accesslog>access.log</accesslog>
    <errorlog>error.log</errorlog>
    <loglevel>3</loglevel>
</logging>
```

### Pas 4 — Habilitar l'inici automàtic

sudo nano /etc/default/icecast2
# Canviar: ENABLE=false → ENABLE=true


### Pas 5 — Iniciar el servei

sudo systemctl enable icecast2
sudo systemctl start icecast2
sudo systemctl status icecast2


---

## 4. Preparar els fitxers d'àudio

### Pas 6 — Crear el directori de música

sudo mkdir -p /opt/icecast/music
sudo chown -R ubuntu:ubuntu /opt/icecast/music


### Pas 7 — Pujar les cançons

# Des del teu ordinador:
scp -i clau.pem cancion.mp3 ubuntu@23.23.53.151:~/radio/music/

---

## 5. Configuració de FFmpeg com a emissor

fichero in "$MUSIC_DIR"/*.mp3; do
        echo "Emitiendo: $fichero"
        ffmpeg -re -i "$fichero" \
               -vn \
               -acodec libmp3lame \
               -ab 128k \
               -ar 44100 \
               -f mp3 \
               -method PUT \
               -content_type audio/mpeg \
               "http://source:${PASSWORD}@localhost:8000/radio"



### Pas 8 — Crear el servei systemd

sudo nano /etc/systemd/system/radio.service


```ini
[Unit]
Description=Icecast Radio Streaming
After=network.target icecast2.service

[Service]
User=ubuntu
Restart=always
RestartSec=5

ExecStart=/usr/bin/ffmpeg -re -stream_loop -1 -f concat -safe 0 -i /home/ubuntu/radio/playlist.txt -c:a libmp3lame -b:a 128k -f mp3 icecast://source:123@localhost:8000/radio.mp3

[Install]
WantedBy=multi-user.target

```
**Explicació dels paràmetres FFmpeg:**

| Paràmetre | Significat |
|-----------|-----------|
| `-re` | Llegir el fitxer a velocitat real (simula streaming en directe) |
| `-vn` | Ignorar el canal de vídeo, només àudio |
| `-acodec libmp3lame` | Codec MP3 LAME |
| `-ab 128k` | Bitrate 128 kbps |
| `-ar 44100` | Freqüència de mostreig 44100 Hz (qualitat CD) |
| `-method PUT` | Mètode HTTP per enviar el flux a Icecast2 |


sudo systemctl daemon-reload
sudo systemctl enable radio
sudo systemctl start radio
sudo systemctl status radio


---

## 6. Ports oberts

AWS Security Group — Inbound Rules:

| Protocol | Port | Origen |
|----------|------|--------|
| TCP | 22 | 0.0.0.0/0 |
| TCP | 8000 | 0.0.0.0/0 |

---

## 7. Proves de validació

### Prova 1 — Pàgina d'estat d'Icecast2
```
http://23.23.53.151:8000
```
Ha d'aparèixer la pàgina d'estat d'Icecast2.


---

### Prova 2 — Panel d'administració
```
http://23.23.53.151:8000/admin
Usuari: admin
Contrasenya: 123
```
Ha de mostrar el mount point `/radio` actiu amb clients connectats.



---

### Prova 3 — Reproducció via navegador
```
http://23.23.53.151:8000/radio
```
El navegador ha de reproduir l'àudio directament.



---

### Prova 4 — Reproducció via VLC
Obrir VLC → **Medios → Abrir URL de red** → `http://23.23.53.151:8000/radio`



---

### Prova 5 — Verificar format MP3
```bash
curl -I http://localhost:8000/radio
```
Ha de mostrar `Content-Type: audio/mpeg`.

> 📸 **CAPTURA 5:** Sortida del comando `curl -I` mostrant `Content-Type: audio/mpeg`.

---

### Prova 6 — Múltiples clients simultanis
Connectar simultàniament navegador + VLC al mateix stream.

> 📸 **CAPTURA 6:** Navegador i VLC oberts al mateix temps reproduint el stream.

---

### Prova 7 — Logs del servidor
```bash
sudo tail -20 /var/log/icecast2/access.log
```
Han d'aparèixer les connexions dels clients.

> 📸 **CAPTURA 7:** Logs d'Icecast2 mostrant les connexions dels clients.

---

## 8. Incidències i solucions

| ID | Incidència | Causa | Solució |
|----|-----------|-------|---------|
| I-001 | Icecast2 no arrencava | `ENABLE=false` a `/etc/default/icecast2` | Canviar a `ENABLE=true` |
| I-002 | Port 8000 no accessible | Security Group AWS amb origen `10.0.0.0/16` | Canviar origen a `0.0.0.0/0` |
| I-003 | FFmpeg `Protocol not found: icy://` | FFmpeg 8.0 no suporta `icy://` | Usar `-method PUT` amb URL HTTP |
| I-004 | Error `405 Method Not Allowed` | Mètode HTTP incorrecte | Afegir `-method PUT` al comando |

---

*Documentació — Projecte Transversal ASIXc1 — ITB — Curs 2025/2026*
