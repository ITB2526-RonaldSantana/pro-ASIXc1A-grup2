# Instal·lació de Graylog amb OpenSearch — Amazon Linux 2023

## Entorn

| Paràmetre | Valor |
|---|---|
| SO | Amazon Linux 2023 |
| Instància AWS | EC2 t3.small |
| IP privada (exemple) | `10.0.4.242` |
| Usuari d'administració | `admin2g` (no root) |
| Accés | Clau pública/privada SSH |
| Motor de cerca | OpenSearch 2.x |

---

## Pas 0 — Preparació inicial

```bash
# Connectar-se al servidor
ssh -i ~/.ssh/clau_privada.pem admin2g@10.0.4.242

# Actualitzar el sistema
sudo dnf update -y

# Instal·lar dependències bàsiques
sudo dnf install -y curl wget tar which

# Configurar el hostname
sudo hostnamectl set-hostname graylog-server
echo "10.0.4.242 graylog-server" | sudo tee -a /etc/hosts
```

---

## Pas 1 — Instal·lar Java 17

```bash
sudo dnf install -y java-17-amazon-corretto-headless

# Verificar
java -version
# Ha de mostrar: openjdk version "17.x.x"

# Establir JAVA_HOME
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto' | sudo tee -a /etc/profile.d/java.sh
source /etc/profile.d/java.sh
```

---

## Pas 2 — Instal·lar MongoDB 6.0

```bash
# Crear el fitxer de repositori
sudo tee /etc/yum.repos.d/mongodb-org-6.0.repo > /dev/null <<EOF
[mongodb-org-6.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2023/mongodb-org/6.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
EOF

# Instal·lar
sudo dnf install -y mongodb-org

# Activar i iniciar
sudo systemctl daemon-reload
sudo systemctl enable mongod
sudo systemctl start mongod

# Verificar
sudo systemctl status mongod
# Ha de mostrar: Active: active (running)
```

---

## Pas 3 — Instal·lar OpenSearch 2.x

### 3.1 Afegir el repositori

```bash
# Crear el fitxer de repositori
sudo tee /etc/yum.repos.d/opensearch-2.x.repo > /dev/null <<EOF
[opensearch-2.x]
name=OpenSearch 2.x repository
baseurl=https://artifacts.opensearch.org/releases/bundle/opensearch/2.x/yum
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://artifacts.opensearch.org/publickeys/opensearch.pgp
enabled=1
EOF

# Instal·lar
sudo OPENSEARCH_INITIAL_ADMIN_PASSWORD=Admin1234! dnf install -y opensearch
```

### 3.2 Configurar OpenSearch

```bash
sudo tee /etc/opensearch/opensearch.yml > /dev/null <<EOF
cluster.name: graylog
node.name: graylog-node1
network.host: 127.0.0.1
http.port: 9200
discovery.type: single-node
plugins.security.disabled: true
action.auto_create_index: false
bootstrap.memory_lock: true
EOF
```

### 3.3 Configurar memòria JVM

```bash
# Per a t3.small (2 GB RAM) — màxim 512 MB per a OpenSearch
sudo tee /etc/opensearch/jvm.options.d/heap.options > /dev/null <<EOF
-Xms512m
-Xmx512m
EOF
```

### 3.4 Permetre memory lock

```bash
sudo mkdir -p /etc/systemd/system/opensearch.service.d
sudo tee /etc/systemd/system/opensearch.service.d/override.conf > /dev/null <<EOF
[Service]
LimitMEMLOCK=infinity
EOF
```

### 3.5 Paràmetre de kernel necessari

```bash
# OpenSearch requereix aquest valor mínim
sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
```

### 3.6 Iniciar OpenSearch

```bash
sudo systemctl daemon-reload
sudo systemctl enable opensearch
sudo systemctl start opensearch

# Esperar ~30 segons i verificar
curl -s http://localhost:9200
# Ha de retornar un JSON amb "cluster_name": "graylog"

# Verificar estat del clúster
curl -s http://localhost:9200/_cluster/health?pretty
# "status" ha de ser "green" o "yellow"
```

---

## Pas 4 — Instal·lar Graylog 5.x

```bash
# Descarregar el paquet RPM del repositori de Graylog
sudo rpm -Uvh https://packages.graylog2.org/repo/packages/graylog-5.1-repository_latest.rpm

# Instal·lar Graylog
sudo dnf install -y graylog-server
```

---

## Pas 5 — Configurar Graylog

### 5.1 Generar secrets

```bash
# Instal·lar pwgen si no hi és
sudo dnf install -y pwgen

# Generar password_secret (mínim 64 caràcters)
pwgen -N 1 -s 96
# Guardar el resultat!

# Generar hash SHA-256 de la contrasenya de l'admin
echo -n "LaTevaContrasenya" | sha256sum
# Guardar el resultat!
```

### 5.2 Editar la configuració

```bash
sudo vi /etc/graylog/server/server.conf
```

Modificar les línies següents:

```ini
password_secret = 8SIdgJ3b5t2eNavxnwxHX3WJpvxm11tYTuFGp5rnwsr8aOXTUhpX2q0dKeviRCJqDLy1xUVF9K6wrwLiquYxlOTwM3rOwwiZ
root_password_sha2 = 9f343730179890b4e08a68290f701bcf614a2e941ed757dfe04a11aa57a15edf
http_bind_address = 0.0.0.0:9000
http_external_uri = http://54.147.23.169:9000/
elasticsearch_hosts = http://127.0.0.1:9200
mongodb_uri = mongodb://localhost/graylog
root_timezone = Europe/Madrid
```

### 5.3 Iniciar Graylog

```bash
sudo systemctl daemon-reload
sudo systemctl enable graylog-server
sudo systemctl start graylog-server

# Verificar (pot trigar 1-2 minuts)
sudo systemctl status graylog-server

# Seguir logs en temps real
sudo journalctl -u graylog-server -f
```

---

## Pas 6 — Obrir ports al Security Group d'AWS

| Port | Protocol | Origen | Descripció |
|---|---|---|---|
| 9000 | TCP | 0.0.0.0/0 | Interfície web Graylog |
| 514 | UDP | VPC CIDR | Syslog UDP |
| 514 | TCP | VPC CIDR | Syslog TCP |
| 12201 | UDP | VPC CIDR | GELF UDP |
| 22 | TCP | La teva IP | SSH administració |

---

## Pas 7 — Configurar un Input a Graylog

Accedir a `http://IP_PUBLICA:9000` (admin / LaTevaContrasenya):

1. **System → Inputs**
2. Seleccionar **Syslog UDP** → **Launch new input**
3. Title: `Syslog-UDP-514`, Port: `514`, Bind: `0.0.0.0`
4. Repetir per a **Syslog TCP** i **GELF UDP (12201)**

---

## Pas 8 — Configurar rsyslog als servidors client

A Amazon Linux 2023, rsyslog ja ve instal·lat per defecte:

```bash
# Verificar que rsyslog està actiu
sudo systemctl status rsyslog

# Afegir la regla de reenviament
echo '*.* @10.0.4.242:514;RSYSLOG_SyslogProtocol23Format' | sudo tee -a /etc/rsyslog.conf

# Reiniciar rsyslog
sudo systemctl restart rsyslog

# Enviar un log de prova
logger -p syslog.info "Test log des de $(hostname)"
```

---

## Pas 9 — Verificació

```bash
# Verificar que OpenSearch té l'índex creat
ssh -i ~/.ssh/clau_privada.pem admin2g@10.0.4.242

# Verificar que arriben logs al port 514
sudo tcpdump -i any -n udp port 514
echo "10.0.4.242 graylog-server" | sudo tee -a /etc/hosts
# Estat dels tres serveis
sudo systemctl status mongod opensearch graylog-server

---

## Pas 10 — Automatització amb Ansible

echo '*.* @10.0.4.242:514;RSYSLOG_SyslogProtocol23Format' | sudo tee -a /etc/rsyslog.conf

```ini
10.0.4.242 ansible_user=admin2g ansible_ssh_private_key_file=~/.ssh/clau_privada.pem

[clients]
10.0.1.10 ansible_user=admin2g ansible_ssh_private_key_file=~/.ssh/clau_privada.pem
10.0.1.20 ansible_user=admin2g ansible_ssh_private_key_file=~/.ssh/clau_privada.pem
10.0.1.30 ansible_user=admin2g ansible_ssh_private_key_file=~/.ssh/clau_privada.pem
```
10.0.4.242 ansible_user=admin2g ansible_ssh_private_key_file=~/.ssh/clau_privada.pem
`playbooks/graylog-amazonlinux.yml`:

```yaml
---
- name: Instal·lar Graylog amb OpenSearch a Amazon Linux 2023
  become: true
  vars:
    graylog_password_secret: "{{ vault_graylog_secret }}"
  graylog_ip: "10.0.4.242"
    opensearch_admin_password: "Admin1234!"

  tasks:
    - name: Actualitzar dnf cache
      dnf:
        update_cache: yes

    - name: Instal·lar dependències
      dnf:
        name:
          - java-17-amazon-corretto-headless
          - curl
          - wget
          - pwgen
        state: present

    - name: Afegir repositori MongoDB
      copy:
        dest: /etc/yum.repos.d/mongodb-org-6.0.repo
        content: |
          [mongodb-org-6.0]
          name=MongoDB Repository
          baseurl=https://repo.mongodb.org/yum/amazon/2023/mongodb-org/6.0/x86_64/
          gpgcheck=1
          enabled=1
          gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc

    - name: Instal·lar MongoDB
      dnf:
        name: mongodb-org
        state: present

    - name: Iniciar MongoDB
      systemd:
        name: mongod
        enabled: yes
        state: started

    - name: Configurar vm.max_map_count
      sysctl:
        name: vm.max_map_count
        value: '262144'
        permanent: yes

    - name: Afegir repositori OpenSearch
      copy:
        dest: /etc/yum.repos.d/opensearch-2.x.repo
        content: |
          [opensearch-2.x]
          name=OpenSearch 2.x repository
          baseurl=https://artifacts.opensearch.org/releases/bundle/opensearch/2.x/yum
          autorefresh=1
          type=rpm-md
          gpgcheck=1
          gpgkey=https://artifacts.opensearch.org/publickeys/opensearch.pgp
          enabled=1

    - name: Instal·lar OpenSearch
      dnf:
        name: opensearch
        state: present
      environment:
        OPENSEARCH_INITIAL_ADMIN_PASSWORD: "{{ opensearch_admin_password }}"

    - name: Configurar OpenSearch
      copy:
        dest: /etc/opensearch/opensearch.yml
        content: |
          cluster.name: graylog
          node.name: graylog-node1
          network.host: 127.0.0.1
          http.port: 9200
          discovery.type: single-node
          plugins.security.disabled: true
          action.auto_create_index: false
          bootstrap.memory_lock: true
        owner: opensearch
        group: opensearch
        mode: '0640'

    - name: Configurar memòria JVM OpenSearch
      copy:
        dest: /etc/opensearch/jvm.options.d/heap.options
        content: |
          -Xms512m
          -Xmx512m

    - name: Configurar memory lock OpenSearch
      copy:
        dest: /etc/systemd/system/opensearch.service.d/override.conf
        content: |
          [Service]
          LimitMEMLOCK=infinity
        mode: '0644'

    - name: Iniciar OpenSearch
      systemd:
        name: opensearch
        enabled: yes
        state: started
        daemon_reload: yes

    - name: Esperar que OpenSearch estigui llest
      uri:
        url: http://localhost:9200
        status_code: 200
      register: result
      until: result.status == 200
      retries: 10
      delay: 10

    - name: Instal·lar repositori Graylog
      dnf:
        name: https://packages.graylog2.org/repo/packages/graylog-5.1-repository_latest.rpm
        state: present
        disable_gpg_check: yes

    - name: Instal·lar Graylog
      dnf:
        name: graylog-server
        state: present

    - name: Copiar configuració Graylog
      template:
        src: templates/server.conf.j2
        dest: /etc/graylog/server/server.conf
        owner: graylog
        group: graylog
        mode: '0640'

    - name: Iniciar Graylog
      systemd:
        name: graylog-server
        enabled: yes
        state: started
        daemon_reload: yes

- name: Configurar rsyslog als clients
  hosts: clients
  become: true
  vars:
    graylog_ip: "10.0.4.242"
  tasks:
    - name: Assegurar que rsyslog està instal·lat
      dnf:
        name: rsyslog
        state: present

    - name: Afegir reenviament de logs
      lineinfile:
        path: /etc/rsyslog.conf
        line: "*.* @{{ graylog_ip }}:514;RSYSLOG_SyslogProtocol23Format"
        state: present
        backup: yes

    - name: Reiniciar rsyslog
      systemd:
        name: rsyslog
        state: restarted

    - name: Enviar log de prova
      command: logger -p syslog.info "Ansible - rsyslog configurat a {{ inventory_hostname }}"
```

Executar:

```bash
ansible-playbook -i inventory/hosts playbooks/graylog-amazonlinux.yml
```

---

## Diferències clau respecte a Ubuntu

| Aspecte | Ubuntu 22.04 | Amazon Linux 2023 |
|---|---|---|
| Gestor de paquets | `apt` | `dnf` |
| Java | `openjdk-17-jre-headless` | `java-17-amazon-corretto-headless` |
| Repositoris | `.list` a `/etc/apt/sources.list.d/` | `.repo` a `/etc/yum.repos.d/` |
| Graylog RPM | `dpkg -i` + `apt install` | `rpm -Uvh` + `dnf install` |
| rsyslog | Cal instal·lar | Ja ve instal·lat per defecte |
| GPG keys | `gpg --dearmor` | `gpgkey=` directe al `.repo` |

---

## Resolució d'errors comuns

| Error | Causa probable | Solució |
|---|---|---|
| OpenSearch no arrenca | `vm.max_map_count` baix | `sudo sysctl -w vm.max_map_count=262144` |
| `cluster health: red` | Manca de memòria | Reduir heap a 256m o canviar a t3.medium |
| Graylog no connecta a OpenSearch | `plugins.security` actiu | Afegir `plugins.security.disabled: true` |
| No arriben logs | Port 514 bloquejat | Revisar Security Group i `sudo firewall-cmd --list-all` |
| Web UI no accessible | Port 9000 no obert | Afegir regla inbound al Security Group |
| `dnf` no troba el paquet | Cache desactualitzada | `sudo dnf clean all && sudo dnf update -y` |
| MongoDB no arrenca | SELinux bloquejant | `sudo setenforce 0` (temporal) o configurar política SELinux |
