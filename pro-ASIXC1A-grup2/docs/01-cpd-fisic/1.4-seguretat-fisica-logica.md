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

## Seguretat lògica

### Restricció d'accés per autorització

- Tots els servidors s'administren amb un **usuari específic no-root**.
- Autenticació exclusivament per **clau pública/privada SSH** (sense contrasenyes).
- Accés per rol: cada usuari/rol té únicament els permisos mínims necessaris (principi de mínim privilegi).

### Firewalls

- **pfSense / OPNsense** en VM dedicada com a firewall perimetral.
- Regles molt restrictives: només es permet el trànsit necessari per port i protocol.
- Xarxa segmentada en VLANs independents:

| VLAN | Nom | Accés permès |
|---|---|---|
| VLAN 10 | Servidors | Trànsit intern entre servidors |
| VLAN 20 | Administració | SSH, consoles de gestió |
| VLAN 30 | DMZ | HTTP/HTTPS, RTMP, ports de streaming |

### Monitorització

- **Zabbix** o **Prometheus + Grafana** per a mètriques de:
  - CPU, RAM i ús de disc de cada servidor.
  - Temperatura i humitat de la sala.
  - Trànsit de xarxa per VLAN.
- Alertes automàtiques per **correu electrònic i Telegram** davant de qualsevol anomalia.

### Còpies de seguretat / Backups

S'aplica la **regla 3-2-1**:

| Còpia | Suport | Ubicació |
|---|---|---|
| Còpia 1 | NAS primari (RAID 5) | Local — Rack 3 |
| Còpia 2 | NAS secundari (RAID 6) | Local — Rack 3 |
| Còpia 3 | AWS S3 | Offsite (núvol) |

- **Còpies incrementals diàries** i **còpies completes setmanals**.
- Retenció de 30 dies.
- Verificació d'integritat mensual (restore test).

### RAIDs

| NAS | Tipus RAID | Discos | Tolerància a fallades |
|---|---|---|---|
| NAS primari | RAID 5 | Mínim 3 | 1 disc simultani |
| NAS secundari | RAID 6 | Mínim 4 | 2 discos simultanis |

> Els RAIDs proporcionen **continuïtat del servei** davant de fallada de disc, però **no substitueixen els backups**.
