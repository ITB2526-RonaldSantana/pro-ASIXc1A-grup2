# Documentación completa

## Índice

01. [01-cpd-fisic](01-cpd-fisic)
   1.1 [1.1-infraestructura-electrica.md](01-cpd-fisic/1.1-infraestructura-electrica.md)
   1.2 [1.2-infraestructura-it.md](01-cpd-fisic/1.2-infraestructura-it.md)
   1.3 [1.3-prevencio-rrll.md](01-cpd-fisic/1.3-prevencio-rrll.md)
   1.4 [1.4-seguretat-fisica-logica.md](01-cpd-fisic/1.4-seguretat-fisica-logica.md)
   1.5 [1.5-ubicacio.md](01-cpd-fisic/1.5-ubicacio.md)
02. [02-aws](02-aws)
   2.1 [ansible.md](02-aws/ansible.md)
   2.2 [arquitectura.md](02-aws/arquitectura.md)
   2.3 [ldap.md](02-aws/ldap.md)
   2.4 [logs-centralitzats.md](02-aws/logs-centralitzats.md)
   2.5 [usuaris-admin.md](02-aws/usuaris-admin.md)
   2.6 [web-sftp.md](02-aws/web-sftp.md)
03. [03-audio](03-audio)
   3.1 [Descripció_de_la_funcionalitat_Audio.md](03-audio/Descripció_de_la_funcionalitat_Audio.md)
04. [04-video](04-video)
   4.1 [Descripció_de_la_funcionalitat_Servei_de_Vídeo.md](04-video/Descripció_de_la_funcionalitat_Servei_de_Vídeo.md)
05. [05-videoconferencia](05-videoconferencia)
   5.1 [Descripció_Protocol_WebRTC.md](05-videoconferencia/Descripció_Protocol_WebRTC.md)
06. [06-amplada-banda](06-amplada-banda)
   - Sin documentos disponibles
07. [07-bd](07-bd)
   7.1 [backup-event.md](07-bd/backup-event.md)
   7.2 [er-diagrama.md](07-bd/er-diagrama.md)
   7.3 [model-relacional.md](07-bd/model-relacional.md)
   7.4 [rols-permisos.md](07-bd/rols-permisos.md)
   7.5 [triggers.md](07-bd/triggers.md)
08. [08-1665](08-1665)
   8.1 [ra3-optimitzacio.md](08-1665/ra3-optimitzacio.md)
   8.2 [ra5-seguretat-dades.md](08-1665/ra5-seguretat-dades.md)
   8.3 [ra6-transformacio-digital.md](08-1665/ra6-transformacio-digital.md)

---

## 01. 01-cpd-fisic

### 1.1 01-cpd-fisic/1.1-infraestructura-electrica.md

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
| 5–10 min | Transició | El grup electrogen arrenca (< 30 s d'arrencada) |
| 10–25 min | Operació normal | Servidors alimentats pel grup electrogen |
| 25 min | Màxim SAI | Apagat controlat si el generador no ha arrencat |

> **Conclusió**: els SAI garanteixen un mínim de **25 minuts d'autonomia**, suficients per a un apagat ordenat o per a l'arrencada del grup electrogen.

## Grup electrogen

- **Combustible**: dièsel.
- **Temps d'arrencada**: < 30 segons des de la detecció de fallada.
- **Autonomia**: il·limitada mentre hi hagi combustible (dipòsit per a 48–72 h d'operació).
- **Commutació automàtica**: ATS (Automatic Transfer Switch) que commuta a la xarxa comercial quan es restableix el subministrament.

### 1.2 01-cpd-fisic/1.2-infraestructura-it.md

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

## Connexions entre racks

- **Rack 1 ↔ Rack 2**: Cat6A des del patch panel del Rack 1 al switch core del Rack 2.
- **Rack 2 ↔ Rack 3**: Cat6A des del switch d'accés al NAS primari i secundari.
- **Tots els racks**: connexió de fibra òptica per al trànsit d'alta velocitat entre racks.

### 1.3 01-cpd-fisic/1.3-prevencio-rrll.md

# Prevenció de riscos laborals (RRLL)

## Mesures aplicades al CPD

La sala del CPD incorpora les mesures de prevenció de riscos laborals obligatòries d'acord amb la normativa vigent (Llei 31/1995 de Prevenció de Riscos Laborals i el Reial Decret 486/1997 sobre llocs de treball).

---

## Riscos identificats i mesures preventives

### Risc elèctric

| Mesura | Descripció |
|---|---|
| Instal·lació elèctrica certificada | Revisió periòdica per electricista autoritzat |
| Posada a terra | Tots els racks i equips connectats a terra |
| Protecció de quadres elèctrics | Armaris tancats amb clau, accés restringit |
| EPIs disponibles | Guants aïllants i calçat de seguretat disponibles a la sala |
| Senyalització | Pictogrames de risc elèctric visibles en tots els quadres |

### Risc d'incendi

| Mesura | Descripció |
|---|---|
| Sistema FM-200 / Novec | Extinció automàtica sense danyar equips ni persones |
| Detectors de fum | Al sostre tècnic i sota el sòl tècnic |
| Alarma contra incendis | Integrada amb el sistema general de l'edifici |
| Vies d'evacuació | Senyalitzades amb llum d'emergència, lliures d'obstacles |
| Extintors | CO₂ (aptes per a focs elèctrics) a l'entrada de la sala |
| Formació | Tot el personal autoritzat format en extinció i evacuació |

### Risc ergonòmic

| Mesura | Descripció |
|---|---|
| Alçada dels racks | Els equips de manipulació freqüent situats entre 0,5 m i 1,7 m d'alçada |
| Eines de suport | Carros elevadors i safates lliscants per a servidors pesants |
| Il·luminació | Mínima 500 lux a la zona de treball (normativa UNE-EN 12464-1) |
| Espai de pas | Passadissos mínims de 1,2 m d'amplada entre racks |

### Risc ambiental (soroll i temperatura)

| Mesura | Descripció |
|---|---|
| Nivell de soroll | Els equips CRAC i servidors generen ~70–80 dB; ús de protectors auditius obligatori en tasques de durada > 30 min |
| Temperatura de treball | Mantinguda entre 18–27 °C per als equips; el personal disposa d'accés a zones amb temperatura de confort |
| Roba adequada | En zones de passadís fred s'ha de portar roba d'abric si la tasca és prolongada |

### Risc de caigudes i cops

| Mesura | Descripció |
|---|---|
| Sòl tècnic | Les baldoses estan fixades i senyalitzades; es col·loquen plafons de senyalització quan s'aixequen per manteniment |
| Il·luminació d'emergència | Activada automàticament en cas de tall elèctric |
| Ordre i neteja | Política de zero cables al sòl; tots els cables passen pel sòl o sostre tècnic |

---

## Procediments de seguretat

1. **Treball en parella**: cap tasca de manteniment elèctric es realitza en solitari.
2. **Permís de treball**: qualsevol intervenció a la sala requereix registre previ al sistema de control d'accés.
3. **Formació obligatòria**: tot el personal que accedeix al CPD ha de tenir formació bàsica en PRL (mínim 6 hores).
4. **Simulacres d'evacuació**: mínim 1 simulacre anual documentat.
5. **Botiquí de primers auxilis**: disponible a l'exterior immediat de la sala del CPD.

---

## Normativa de referència

- Llei 31/1995, de 8 de novembre, de Prevenció de Riscos Laborals.
- Reial Decret 486/1997: disposicions mínimes de seguretat i salut en els llocs de treball.
- Reial Decret 614/2001: disposicions mínimes per a la protecció de la salut i seguretat dels treballadors davant el risc elèctric.
- Norma UNE-EN 12464-1: il·luminació de llocs de treball interiors.
- Norma TIA-942: estàndard d'infraestructura de telecomunicacions per a CPDs.

### 1.4 01-cpd-fisic/1.4-seguretat-fisica-logica.md

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

### 1.5 01-cpd-fisic/1.5-ubicacio.md

# Ubicació física del CPD

## Situació a l'edifici

La sala del CPD s'ubica en una **planta intermèdia** de l'edifici, evitant:

- **Planta baixa**: vulnerable a inundacions i accessos no autoritzats.
- **Última planta**: exposada a filtracions d'aigua de pluja i variacions tèrmiques extremes.

La sala no disposa de finestres exteriors i l'accés físic només és possible des d'una zona restringida de l'edifici, no des de passadissos comuns.

## Mesures per dificultar la identificació de la sala

- La porta no porta cap retolació identificativa.
- S'integra visualment com una sala tècnica genèrica.
- Sense senyalització externa que indiqui la presència d'equipament crític.
- Accés únicament des de zona de pas restringida al personal autoritzat.

## Distribució i gestió del cablejat

- **Sòl tècnic**: elevat entre 30–45 cm sobre el sòl estructural. Per aquest espai circulen:
  - Cables de dades (Cat6A i fibra òptica)
  - Cables elèctrics
  - Aire fred provinent de les unitats CRAC
  - Les baldoses són metàl·liques antiestàtiques.

- **Sostre tècnic**: bandeja de cablejat per sobre dels racks per al retorn de l'aire calent i els cables d'alimentació. Alçada lliure mínima de 2,5 m sobre el sòl tècnic.

## Sistema de climatització

S'utilitzen unitats **CRAC** (Computer Room Air Conditioning) amb flux d'aire fred per sòl tècnic, seguint el model de contenció d'aire calent/fred:

| Zona | Temperatura | Humitat relativa |
|---|---|---|
| Passadís fred | 18–21 °C | 40–60% |
| Passadís calent | 27–35 °C | — |
| General sala | 18–27 °C | 40–60% |

- Sistemes redundants N+1: si una unitat CRAC falla, l'altra assumeix la càrrega total.
- Dos unitats CRAC (CRAC 1 i CRAC 2) situades als extrems de la sala.
- Filtratge d'aire per eliminar partícules i mantenir la qualitat de l'aire.

## Terra tècnic i sostre tècnic

### Terra tècnic
- Alçada: 40 cm sobre el sòl estructural.
- Material: baldoses metàl·liques antiestàtiques de 60×60 cm.
- Funció: distribució d'aire fred, pas de cablejat de dades i elèctric.
- Càrrega màxima: 1.000 kg/m².

### Sostre tècnic
- Bandejas de cablejat per a cables elèctrics i de dades.
- Retorn de l'aire calent cap a les unitats CRAC.
- Sistemes de detecció d'incendis integrats.

## Estructuració dels racks

El CPD disposa de **3 racks** distribuïts seguint el model de passadissos freds/calents:

| Rack | Contingut principal |
|---|---|
| Rack 1 | Servidors (Web, SFTP, LDAP, Logs, Àudio/Vídeo, BD, Backups) + SAI 1 |
| Rack 2 | Equipament de xarxa (Switch core, Switch accés, Firewall, Patch panels, KVM) + SAI 2 |
| Rack 3 | Emmagatzematge (NAS primari RAID 5, NAS secundari RAID 6, Fibra) + SAI 3 |

La disposició segueix el patró:

```
[CRAC 1] | Passadís Fred | RACK 1 | Passadís Calent | RACK 2 | Passadís Fred | RACK 3 | [CRAC 2]
```

---

## 02. 02-aws

### 2.1 02-aws/ansible.md

# 2.1 Gestió de les màquines amb Ansible

## 2.1.1 Decisió adoptada

Per a la gestió i configuració dels servidors del CPD he decidit utilitzar **Ansible** com a eina d'automatització. Això significa que totes les instal·lacions, configuracions i desplegaments es fan des d'una màquina de control mitjançant playbooks, sense haver d'accedir manualment a cada servidor.
S'administressin i configuressin 3 maquines i 4 serveis amb ansible, aquesta és la distribució:

- Servidor 1 ( Servei Web + SFTP )
- Servidor 2A ( LDAP )
- Servidor 2B ( Centralització de Logs )

## 2.1.2 Usuari de gestió

Per no utilitzar l'usuari per defecte d'AWS, per a les tasques d'Ansible, s'ha creat un usuari dedicat anomenat **`ansible`** a cada servidor.

Aquest usuari té les característiques següents:

- Pot executar ordres amb `sudo` sense necessitat de contrasenya, necessari perquè Ansible pugui instal·lar paquets i modificar configuracions del sistema.
- L'autenticació es fa exclusivament mitjançant **clau SSH**. No té contrasenya d'accés.
- La clau privada es troba a la màquina de control. Cap servidor no la conté.

## 2.1.3 Estructura de carpetes node de gestió Ansible

El node de gestió de Ansible serà una màquina externa al CPD que tindrà la següent estructura de carpetes i arxius per a aquesta gestió:

```
ansible-cpd/
├── inventory.ini          # Llista de servidors i les seves IPs
├── site.yml               # Assignació de rols a cada servidor
├── group_vars/
│   └── all.yml            # Variables compartides per tots els servidors
└── roles/
    ├── common/            # Configuració base aplicada als 3 servidors
    ├── nginx/             # Servidor web (Servidor 1)
    ├── proftpd/           # SFTP amb autenticació LDAP (Servidor 1)
    ├── slapd/             # Directori actiu OpenLDAP (Servidor 2A)
    └── graylog/           # Centralització de logs (Servidor 2B)
```
### inventory.ini
 
Conté la llista de màquines que Ansible gestionarà, agrupades per funció. El Servidor 2 apareix en dos grups diferents perquè allotja dos serveis independents: LDAP i Graylog.
 
### site.yml
 
Assigna els rols a cada grup de servidors. Defineix **qui fa què**: quins serveis s'instal·len i configuren a cada màquina.
 
### group_vars/all.yml
 
Conté les variables que comparteixen diversos rols, com ara el domini LDAP, la IP del servidor de directori, les credencials d'administració o la zona horària. Centralitzar-les aquí evita repetir el mateix valor en múltiples llocs.

### Rols
 
Cada rol és independent i conté tot el necessari per desplegar un servei:
 
- `tasks/main.yml` — els passos d'instal·lació i configuració
- `templates/` — fitxers de configuració amb variables (vhost de Nginx, `proftpd.conf`, fitxers LDIF, `graylog.conf`)
- `vars/main.yml` — variables pròpies del servei (llista d'usuaris LDAP, ports, directoris)
- `handlers/main.yml` — accions reactives com reiniciar un servei quan canvia la seva configuració

## 2.1.4 Fitxers de configuració desplegats
 
Un dels aspectes més importants és que Ansible no només instal·la els paquets, sinó que també desplega i gestiona els fitxers de configuració de cada servei:
 
- **Nginx** — virtualhost configurat amb el domini i el directori arrel del projecte
- **ProFTPD** — `proftpd.conf` amb mode SFTP, chroot per usuari i connexió al servidor LDAP
- **slapd** — fitxers LDIF per crear l'estructura del directori (`ou=users`, `ou=groups`) i els usuaris inicials
- **Graylog** — `server.conf` amb la connexió a MongoDB i OpenSearch, i `opensearch.yml` ajustat per al tipus d'instància t3.small
Aquests fitxers s'escriuen com a plantilles Jinja2 (extensió `.j2`). Contenen variables com `{{ ldap_base_dn }}` o `{{ ldap_server_ip }}` que Ansible substitueix pels valors reals de `group_vars/all.yml` en el moment del desplegament. Així, si canvia una IP o un domini, només cal modificar un valor i tornar a llançar el playbook.

### 2.2 02-aws/arquitectura.md

*Documento vacío.*

### 2.3 02-aws/ldap.md

*Documento vacío.*

### 2.4 02-aws/logs-centralitzats.md

*Documento vacío.*

### 2.5 02-aws/usuaris-admin.md

*Documento vacío.*

### 2.6 02-aws/web-sftp.md

*Documento vacío.*

---

## 03. 03-audio

### 3.1 03-audio/Descripció_de_la_funcionalitat_Audio.md

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

sudo apt install icecast2


### Client multimèdia

sudo apt install vlc

---

## 04. 04-video

### 4.1 04-video/Descripció_de_la_funcionalitat_Servei_de_Vídeo.md

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

---

## 05. 05-videoconferencia

### 5.1 05-videoconferencia/Descripció_Protocol_WebRTC.md

# Protocol WebRTC

## Descripció

WebRTC (Web Real-Time Communication) és una tecnologia de comunicació en temps real que permet establir connexions d’àudio, 
vídeo i intercanvi de dades directament entre navegadors web i dispositius sense necessitat d’instal·lar programari addicional.

Aquest protocol és utilitzat en aplicacions de videoconferència com Jitsi Meet, permetent comunicacions segures i amb baixa latència.

## Característiques principals

- Comunicació en temps real entre usuaris.
- Transmissió d’àudio i vídeo amb baixa latència.
- Compatibilitat amb navegadors moderns.
- Connexions xifrades i segures mitjançant DTLS i SRTP.
- Comunicació peer-to-peer (P2P).
- Compartició de pantalla i dades.

## Funcionament

El funcionament de WebRTC es basa en tres fases principals:

1. Intercanvi d’informació entre clients.
2. Establiment de la connexió directa.
3. Transmissió dels fluxos multimèdia.

## Objectiu del protocol

Aquesta tecnologia és especialment adequada per a sistemes de videoconferència empresarials, ja que permet comunicacions eficients, segures i accessibles des de qualsevol navegador modern.

## Paquets utilitzats

### Plataforma de videoconferència

sudo apt install jitsi-meet


### Dependències principals

sudo apt install openjdk-17-jre-headless
sudo apt install nginx

---

## 06. 06-amplada-banda

*Sin documentos disponibles en esta carpeta.*

## 07. 07-bd

### 7.1 07-bd/backup-event.md

*Documento vacío.*

### 7.2 07-bd/er-diagrama.md

*Documento vacío.*

### 7.3 07-bd/model-relacional.md

*Documento vacío.*

### 7.4 07-bd/rols-permisos.md

*Documento vacío.*

### 7.5 07-bd/triggers.md

*Documento vacío.*

---

## 08. 08-1665

### 8.1 08-1665/ra3-optimitzacio.md

*Documento vacío.*

### 8.2 08-1665/ra5-seguretat-dades.md

*Documento vacío.*

### 8.3 08-1665/ra6-transformacio-digital.md

*Documento vacío.*

---
