# Servei de Vídeo

## Descripció de la funcionalitat

El servei de vídeo implementat permet la distribució de contingut audiovisual en streaming mitjançant protocols de transmissió multimèdia adaptats a entorns web i xarxes corporatives.

Per a la implementació s’utilitza un servidor NGINX amb el mòdul RTMP, encarregat de gestionar la recepció i distribució dels fluxos de vídeo, 
El sistema permet transmetre contingut en directe i oferir accés als vídeos des de navegadors web i clients multimèdia.

El servei utilitza:

- Protocol RTMP per a l’enviament del flux de vídeo.
- Protocol HLS per a la reproducció web.
- Còdec H.264 per a la compressió de vídeo.
- Format MP4 per a l’emmagatzematge i compatibilitat.

## Funcionalitats principals

- Streaming de vídeo en temps real.
- Accés remot des de navegador web.
- Compatibilitat amb diferents dispositius i clients.
- Distribució eficient del contingut multimèdia.
- Possibilitat de múltiples connexions simultànies.

## Objectiu del servei

Aquest sistema permet donar suport a la comunicació corporativa, la formació interna i la distribució de continguts audiovisuals als clients de l’empresa.

## Paquets utilitzats

### Servidor de vídeo

sudo apt install nginx
sudo apt install libnginx-mod-rtmp
sudo apt install ffmpeg


### Client de reproducció

sudo apt install vlc
