# Servei de centralització de logs — Graylog

## Descripció del servei

El servei de centralització de logs permet recollir, emmagatzemar i analitzar en temps real tots els registres d'activitat generats pels servidors del CPD d'InnovateTech. Qualsevol esdeveniment que passi a qualsevol màquina queda registrat en un únic punt, facilitant la detecció d'errors, la monitorització i l'auditoria del sistema.

## Tecnologies utilitzades

| Component | Tecnologia | Funció |
|---|---|---|
| Servidor de logs | Graylog 5.x | Recepció, classificació i visualització de logs |
| Motor de cerca | OpenSearch 2.x | Indexació i emmagatzematge dels logs |
| Base de dades | MongoDB 6.0 | Configuració i metadades de Graylog |
| Agent client | rsyslog | Enviament de logs des de cada servidor |
| Infraestructura | AWS EC2 t3.medium | Instància on corre el servei |

## Arquitectura

```
Servidor web     ─┐
Servidor LDAP    ─┤  rsyslog (UDP 514)  ──►  Graylog  ──►  OpenSearch
Servidor BD      ─┤                              │
Servidor backup  ─┘                          MongoDB
                                                 │
                                            Web UI :9000
```

Tots els servidors clients envien els seus logs via **UDP al port 514** cap al servidor Graylog. Graylog els indexa a OpenSearch i els fa accessibles a través de la interfície web.

## Infraestructura AWS

- **Instància**: EC2 t3.medium (4 GB RAM — necessari per córrer MongoDB + OpenSearch + Graylog simultàniament).
- **IP elàstica**: assignada a la instància per garantir que la URL d'accés no canvia entre reinicis.
- **Security Groups**:

| Port | Protocol | Origen | Descripció |
|---|---|---|---|
| 9000 | TCP | 0.0.0.0/0 | Interfície web Graylog |
| 514 | UDP | VPC CIDR | Recepció de logs dels clients |
| 22 | TCP | IP administrador | Accés SSH |

## Configuració del servidor

### Graylog — paràmetres principals (`/etc/graylog/server/server.conf`)

```ini
password_secret = <secret_96_chars>
root_password_sha2 = <sha256_de_la_contrasenya>
http_bind_address = 0.0.0.0:9000
http_external_uri = http://IP_ELASTICA:9000/
elasticsearch_hosts = http://127.0.0.1:9200
mongodb_uri = mongodb://localhost/graylog
root_timezone = Europe/Madrid
message_journal_max_size = 1gb
```

> El paràmetre `message_journal_max_size` s'ha ajustat a 1 GB per adaptar-se a la mida del disc de la instància. El valor per defecte de 5 GB superava l'espai disponible i impedia l'arrencada del servei.

### OpenSearch — paràmetres principals (`/etc/opensearch/opensearch.yml`)

```yaml
cluster.name: graylog
node.name: graylog-node1
network.host: 127.0.0.1
http.port: 9200
discovery.type: single-node
plugins.security.disabled: true
action.auto_create_index: false
bootstrap.memory_lock: true
```

> `plugins.security.disabled: true` és necessari per a ús en xarxa interna. OpenSearch activa la seguretat per defecte, cosa que impedeix la connexió de Graylog sense certificats SSL.

### Memòria JVM d'OpenSearch (`/etc/opensearch/jvm.options.d/heap.options`)

```
-Xms512m
-Xmx512m
```

> Limitat a 512 MB per deixar memòria suficient per a MongoDB i Graylog a la mateixa instància.

## Configuració dels clients

Cada servidor que ha d'enviar logs té instal·lat **rsyslog** amb el fitxer `/etc/rsyslog.d/graylog.conf`:

```
*.* @IP_PRIVADA_GRAYLOG:514;RSYSLOG_SyslogProtocol23Format
```

- `*.*` — envia tots els logs de qualsevol nivell de severitat.
- `@` — protocol UDP (més lleuger, adequat per a logs interns).
- `IP_PRIVADA_GRAYLOG` — s'utilitza la IP privada de la VPC, no la IP elàstica, per mantenir el trànsit dins de la xarxa interna d'AWS.

> En Amazon Linux 2023, rsyslog **no ve instal·lat per defecte** i cal instal·lar-lo manualment amb `sudo dnf install -y rsyslog`.

## Inputs configurats a Graylog

| Input | Port | Protocol | Estat |
|---|---|---|---|
| Syslog UDP | 514 | UDP | Running |

Els inputs es configuren des de **System → Inputs** a la interfície web i defineixen com Graylog escolta els logs entrants.

## Incidències i solucions

### Graylog no arrencava — espai en disc insuficient

**Error**: `Journal directory has not enough free space. You need to provide additional 1573 MB`

**Causa**: el valor per defecte de `message_journal_max_size` és 5120 MB, superior a l'espai lliure disponible al disc de la instància.

**Solució**: reduir el paràmetre a 1 GB al `server.conf`:
```ini
message_journal_max_size = 1gb
```

### La instància anava molt lenta

**Causa**: MongoDB + OpenSearch + Graylog consumien tota la RAM d'una instància t3.small (2 GB).

**Solució**: canviar la instància a t3.medium (4 GB RAM) des de la consola d'AWS.

### rsyslog no existia a Amazon Linux 2023

**Causa**: Amazon Linux 2023 no inclou rsyslog per defecte, a diferència d'Ubuntu.

**Solució**: instal·lar-lo manualment:
```bash
sudo dnf install -y rsyslog
sudo systemctl enable rsyslog
sudo systemctl start rsyslog
```

### Els logs no apareixien a Graylog

**Causa**: el fitxer `/etc/rsyslog.conf` no existia. A Amazon Linux 2023 la configuració va a `/etc/rsyslog.d/`.

**Solució**: crear el fitxer `/etc/rsyslog.d/graylog.conf` amb la regla de reenviament.

## Verificació del funcionament

```bash
# Estat dels 4 serveis
sudo systemctl status mongod opensearch graylog-server rsyslog

# Port 514 escoltant
sudo ss -ulnp | grep 514

# Enviar log de prova
logger -p syslog.info "Test log des de $(hostname)"
```

A la web UI → **Search** el missatge apareix en temps real.

## Accés a la interfície web

```
URL:        http://IP_ELASTICA:9000
Usuari:     admin
```

> S'utilitza IP elàstica per garantir que la URL no canvia entre reinicis de la instància.
