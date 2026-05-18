# Fichero combinado de Markdown

Este fichero reúne todos los archivos .md del repositorio en el orden alfabético de rutas.

---

## README.md


---

## docs/02-aws/usuaris-admin.md


---

## docs/02-aws/web-sftp.md


---

## docs/02-aws/ldap.md


---

## docs/02-aws/logs-centralitzats.md


---

## docs/02-aws/arquitectura.md


---

## docs/02-aws/ansible.md


---

## docs/04-video/README.md


---

## docs/01-cpd-fisic/1.1-infraestructura-electrica.md

# 1.1 Infraestructura elèctrica

## Sistemes d'alimentació redundant

El CPD disposa de **dues línies elèctriques independents** (Línia A i Línia B) que garanteixen la continuïtat del servei en cas de fallada d'una d'elles. A més, com a última capa de protecció, s'incorpora un **grup electrogen de dièsel**.

```
Xarxa elèctrica
      │
   ┌──┴──┐
Línia A  Línia B
   │        │
   └──┬─────┘
      │
   [SAI 1]  [SAI 2]  [SAI 3]
      │        │        │
   Rack 1   Rack 2   Rack 3
                            \
                      [Grup electrogen]
                       Arrenca en < 30 s
```

## SAI (Sistemes d'Alimentació Ininterrompuda)

### Càlcul de la càrrega

| Equip | Unitats | W/unitat | Total W |
|---|---|---|---|
| Servidors (4 EC2 equiv.) | 4 | 300 W | 1.200 W |
| Switches (core + accés) | 2 | 80 W | 160 W |
| NAS primari + secundari | 2 | 120 W | 240 W |
| KVM + patch panels | 1 | 30 W | 30 W |
| Unitats CRAC (climatitz.) | 2 | 400 W | 800 W |
| **Subtotal** | | | **2.430 W** |
| **Factor de seguretat +20%** | | | **+486 W** |
| **Càrrega total estimada** | | | **≈ 2.900 W** |

### SAI seleccionats

S'instal·len **3 SAI de 3.000 VA / 2.700 W**, un per rack:

| SAI | Rack | Càrrega protegida | Mòduls EBM |
|---|---|---|---|
| SAI 1 | Rack 1 — Servidors | Servidors 1–4 | 2 mòduls |
| SAI 2 | Rack 2 — Xarxa | Switches, firewall, KVM | 2 mòduls |
| SAI 3 | Rack 3 — Emmagatzematge | NAS primari i secundari | 1 mòdul |

### Càlcul d'autonomia

Amb 2 mòduls EBM per SAI, l'autonomia estimada a plena càrrega (2.900 W) és:

| Fase | Temps | Acció |
|---|---|---|
| 0 min | Tall elèctric | SAI entra en funcionament automàticament |
| 0–2 min | SAI actiu | Subministrament ininterromput als equips |
| 2–5 min | Alarma | Notificació automàtica als administradors |
| 5–10 min | Transición | El grup electrogen arrenca (< 30 s d'arrencada) |
| 10–25 min | Operació normal | Servidors alimentats pel grup electrogen |
| 25 min | Màxim SAI | Apagat controlat si el generador no ha arrencat |

> **Conclusió**: els SAI garanteixen un mínim de **25 minuts d'autonomia**, suficients per a un apagat ordenat o per a l'arrencada del grup electrogen.

## Grup electrogen

- **Combustible**: dièsel.
- **Temps d'arrencada**: < 30 segons des de la detecció de fallada.
- **Autonomía**: il·limitada mentre hi hagi combustible (dipòsit per a 48–72 h d'operació).
- **Commutació automàtica**: ATS (Automatic Transfer Switch) que commuta a la xarxa comercial quan es restableix el subministrament.

---

## docs/01-cpd-fisic/1.4-seguretat-fisica-logica.md

# Seguretat física i lògica

## Seguretat física

### Control d'accés

- **Doble factor obligatori**: lector de targeta RFID + teclado PIN.
- La porta és **blindada** amb tancament electromagnètic en mode **fail-secure** (tanca en cas de fallada elèctrica).
- Registre automàtic de totes les entrades i sortides amb timestamp i identificació d'usuari.
- Accés restringit exclusivament al personal autoritzat amb fitxa individual.

### Videovigilància

| Element | Especificació |
|---|---|
| Càmeres | 3 càmeres IP domo 180° |
| Cobertura | 2 interiors (cantonades) + 1 exterior (porta) |
| Gravació | Contínua 24/7 en NVR local |
| Retenció | Mínim 30 dies |
| Visió nocturna | Infraroja (IR) |

### Prevenció, detecció i extinció d'incendis

- **Sistema d'extinció**: gas inert **FM-200** (o Novec 1230).
  - No danya els equips electrònics.
  - No deixa residu.
  - Actua en menys de 10 segons.
- **Detectors de fum i temperatura**: al sostre tècnic i sota el sòl tècnic.
- **Alarma contra incendis**: integrada amb el sistema de control d'accés (obtura portes cortafoc).

### Vies d'evacuació

- Senyalització lluminosa d'emergència en tots els punts de sortida.
- Porta d'emergència amb barra antipànic (fail-open en cas d'incendi).
- Pla d'evacuació visible a l'entrada de la sala.

### Control d'humitat

Els nivells objectiu de humitat relativa (HR) se situen entre el **40% i el 60%**:

- Per sota del 40%: risc d'electricitat estàtica que pot danyar components electrònics.
- Per sobre del 60%: risc de condensació sobre circuits i connectors.

**Mesures preventives:**

- Les unitats **CRAC** ja incorporen control d'humitat integrat — deshumidifiquen quan la HR puja i humidifiquen quan baixa. És la primera línia de defensa.
- **Segellat de forats i passacables**: totes les entrades de cables al sòl tècnic, parets i sostre tècnic han d'estar segellades amb escuma ignífuga o masilla tallafoc. Els forats sense segellar són la principal via d'entrada d'humitat exterior.
- **Vapor barrier**: làmina de polietilè sota el sòl tècnic si l'edifici té risc d'humitat ascendent.
- **Porta hermètica**: la porta blindada disposa de junta de goma perimetral per evitar la infiltració d'aire humit de l'exterior.
- **Cap canonada d'aigua** sobre els racks ni passant per la sala. Les unitats CRAC tenen circuit tancat propi.

**Detecció:**

- **Sensors de temperatura i humitat** en tres punts: entrada d'aire fred (sota el sòl tècnic), sortida d'aire calent (sostre) i zona central de la sala.
- **Cable detector d'aigua** sota el sòl tècnic, especialment sota les unitats CRAC, on pot haver-hi condensació. Genera alarma en contacte amb qualsevol líquid.
- **Integració amb Zabbix/Grafana**: alerta automàtica si la HR surt del rang 40–60% durant més de 15 minuts.

| Mesura | Tipus | Especificació |
|---|---|---|
| Unitats CRAC amb control HR | Preventiva | Manté 40–60% HR |
| Segellat de forats i passacables | Preventiva | 100% dels orificis |
| Sensors HR + temperatura | Detecció | Alerta si HR < 40% o > 60% |
| Cable detector d'aigua | Detecció | Sota sòl tècnic i CRAC |
| Cap canonada d'aigua sobre racks | Preventiva | Norma de disseny |

---

## docs/01-cpd-fisic/1.2-infraestructura-it.md

# 1.2 Infraestructura IT

## Servidors

El CPD disposa de **4 servidors** instal·lats al Rack 1, cadascun dedicat a un servei específic (sense AMIs preconfigurades del marketplace d'AWS):

| Servidor | Servei | Instància AWS |
|---|---|---|
| Servidor 1 | Servei web (Apache/Nginx) + SFTP (OpenSSH autenticat via LDAP) | EC2 t3.small |
| Servidor 2 | Directori actiu LDAP (OpenLDAP / Samba AD) + Centralització de logs (Graylog + Opensearch) | EC2 t3.small |
| Servidor 3 | Streaming àudio (Icecast) + Vídeo (NGINX-RTMP) + Base de dades (MySQL/MariaDB) | EC2 t3.medium |
| Servidor 4 | Backups automatitzats | EC2 t3.micro |

> Cada servei s'instal·la en un servidor diferent, a excepció del servei web i SFTP que comparteixen instància.

### Administració dels servidors

- Accés únicament amb **usuari específic no-root** creat manualment.
- Autenticació exclusivament per **clau pública/privada SSH** (sense contrasenyes).
- Mínim **2 màquines configurades amb Ansible** (playbooks documentats al GitHub).

## Patch panels

- **2 patch panels de 24 ports Cat6A** al Rack 1 (dades).
- **1 patch panel de fibra òptica** al Rack 3 (connexió entre racks i cap a l'exterior).
- Tots els cables etiquetats en ambdós extrems.

## Switches

| Dispositiu | Ubicació | Descripció |
|---|---|---|
| Switch core | Rack 2 | Cisco Catalyst 2960 — gestió de VLANs i enrutament intern |
| Switch d'accés | Rack 2 | 48 ports — connexió de servidors i dispositius finals |

### VLANs configurades

| VLAN | Nom | Ús |
|---|---|---|
| VLAN 10 | Servidors | Trànsit entre servidors |
| VLAN 20 | Administració | Accés SSH i gestió |
| VLAN 30 | DMZ | Serveis exposats a Internet |

## Diagrama de distribució dels racks

```
┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐
│     RACK 1      │   │     RACK 2      │   │     RACK 3      │
│   Servidors     │   │     Xarxa       │   │ Emmagatzematge  │
├─────────────────┤   ├─────────────────┤   ├─────────────────┤
│ Patch panel 24p │   │ Switch core     │   │ NAS primari     │
│ Servidor 1      │   │ Switch accés    │   │  └ RAID 5 24TB  │
│ Servidor 2      │   │ Firewall        │   │ NAS secundari   │
│ Servidor 3      │   │ Patch panel 24p │   │  └ RAID 6       │
│ Servidor 4      │   │ KVM Switch      │   │ Patch panel     │
│                 │   │                 │   │  fibra òptica   │
│ SAI 1           │   │ SAI 2           │   │ SAI 3           │
│ 3000VA / 2700W  │   │ 3000VA / 2700W  │   │ 1500VA          │
└─────────────────┘   └─────────────────┘   └─────────────────┘
        │                     │                     │
        └─────────────────────┴─────────────────────┘
                    Connexions Cat6A / Fibra
```

---

## docs/01-cpd-fisic/1.3-prevencio-rrll.md

# Prevenció de riscos laborals (RRLL)

## Mesures aplicades al CPD

La sala del CPD incorpora les mesures de prevenció de riscos laborals obligatòries d'acord amb la normativa vigent (Llei 31/1995 de Prevenció de Riscos Laborals i el Reial Decret 486/1997 sobre llocs de treball).

---

## docs/01-cpd-fisic/1.5-ubicacio.md

# Ubicació física del CPD

## Situació a l'edifici

La sala del CPD s'ubica en una **planta intermèdia** de l'edifici, evitant:

- **Planta baixa**: vulnerable a inundacions i accessos no autoritzats.
- **Última planta**: exposada a filtracions d'aigua de pluja i variacions tèrmiques extremes.

La sala no disposa de finestres exteriors i l'accés físic només és possible des d'una zona restringida de l'edifici, no des de passadissos comuns.

---

## docs/07-bd/rols-permisos.md


---

## docs/07-bd/model-relacional.md


---

## docs/07-bd/triggers.md


---

## docs/07-bd/backup-event.md


---

## docs/07-bd/er-diagrama.md


---

## docs/03-audio/README.md


---

## docs/05-videoconferencia/README.md


---

## docs/08-1665/ra5-seguretat-dades.md


---

## docs/08-1665/ra6-transformacio-digital.md


---

## docs/08-1665/ra3-optimitzacio.md


