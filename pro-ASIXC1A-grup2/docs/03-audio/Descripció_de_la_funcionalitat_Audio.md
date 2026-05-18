# Servei d'Àudio

## Descripció de la funcionalitat

El servei d’àudio implementat permet la distribució de contingut multimèdia en temps real mitjançant tecnologia de streaming,
aquest sistema facilita la transmissió d’àudio tant en directe com sota demanda a múltiples clients simultàniament a través de la xarxa.

Per a la implementació s’utilitza un servidor Icecast2, que actua com a servidor central de distribució d’àudio. 
Els clients poden accedir al contingut utilitzant navegadors web o reproductors multimèdia compatibles com VLC Media Player.

El servei és compatible amb formats digitals d’àudio com:

- MP3
- AAC
- OGG

## Funcionalitats principals

- Distribució d’àudio en *streaming* en temps real.
- Accés simultani de múltiples usuaris.
- Compatibilitat amb navegadors web.
- Reproducció remota mitjançant reproductors multimèdia.
- Gestió de canals d’àudio.

## Objectiu del servei

Aquest sistema permet millorar la comunicació interna de l’empresa i facilitar la distribució de contingut multimèdia als clients de forma eficient i escalable.

## Paquets utilitzats

### Servidor
```bash
sudo apt install icecast2
```

### Client multimèdia
```bash
sudo apt install vlc
```
