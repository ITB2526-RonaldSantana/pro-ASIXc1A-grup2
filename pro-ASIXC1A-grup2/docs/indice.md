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
  2.2 [graylog.md](02-aws/graylog.md)

03. [03-audio](03-audio)
  3.1 [Descripció_de_la_funcionalitat_Audio.md](03-audio/Descripció_de_la_funcionalitat_Audio.md)

04. [04-video](04-video)
  4.1 [Descripció_de_la_funcionalitat_Servei_de_Vídeo.md](04-video/Descripció_de_la_funcionalitat_Servei_de_Vídeo.md)

05. [05-videoconferencia](05-videoconferencia)
  5.1 [Descripció_Protocol_WebRTC.md](05-videoconferencia/Descripció_Protocol_WebRTC.md)

06. [06-amplada-banda](06-amplada-banda)
  - Sin documentos disponibles

07. [07-bd](07-bd)
  7.1 [er-diagrama.md](07-bd/er-diagrama.md)
  7.2 [model-relacional.md](07-bd/model-relacional.md)

08. [08-1665](08-1665)
  - Sin documentos disponibles

---

## Capturas (carpeta capturas/)

La carpeta `capturas/` conté imatges i captures organitzades per temàtiques. Aquestes figures es poden utilitzar com a suport visual en les pàgines corresponents de la documentació.

### 01-cpd-fisic
- `capturas/01-cpd-fisic/CPD-LOGICA.svg` — Diagrama lògic del CPD.
- `capturas/01-cpd-fisic/VISTAISOMETRICA.svg` — Vista isomètrica del CPD.
- `capturas/01-cpd-fisic/VISTA2D.svg` — Vista 2D del CPD.
- `capturas/01-cpd-fisic/LOGICA-SAIS.svg` — Diagrama de l'alimentació i dels SAIs.
- `capturas/01-cpd-fisic/infraestructura-it.png` — Esquema d'infraestructura IT i distribució dels racks.
- `capturas/01-cpd-fisic/RED.png` — Topologia de xarxa del CPD.

![CPD - Diagrama lògic](../capturas/01-cpd-fisic/CPD-LOGICA.svg)
![CPD - Vista isomètrica](../capturas/01-cpd-fisic/VISTAISOMETRICA.svg)
![CPD - Vista 2D](../capturas/01-cpd-fisic/VISTA2D.svg)
![CPD - SAI](../capturas/01-cpd-fisic/LOGICA-SAIS.svg)
![CPD - Infraestructura IT](../capturas/01-cpd-fisic/infraestructura-it.png)
![CPD - Xarxa](../capturas/01-cpd-fisic/RED.png)

Referència: [01-cpd-fisic](01-cpd-fisic)

### 07-bd
 - `capturas/07-bd/er-diagrama/RAPJ-SQL.png` — Diagrama de la base de dades SQL.
 - `capturas/07-bd/er-diagrama/RAPJ-E-R.png` — Diagrama entitat-relació.

Referència: [07-bd](07-bd)

### 07-bd
- `capturas/07-bd/er-diagrama/RAPJ-SQL.png` — Diagrama de la base de dades SQL.
- `capturas/07-bd/er-diagrama/RAPJ-E-R.png` — Diagrama entitat-relació.

Referència: [07-bd](07-bd)

### Altres carpetes
- `capturas/03-audio/README.md`
- `capturas/04-video/README.md`
- `capturas/05-videoconferencia/README.md`
- `capturas/06-amplada-banda/README.md`
- `capturas/08-1665/README.md`

Aquestes carpetes estan presents però no contenen imatges addicionals per a la documentación actual.

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

## 2.1.2 Usuari de gestió

Per no utilitzar l'usuari per defecte d'AWS, per a les tasques d'Ansible, s'ha creat un usuari dedicat anomenat **`usuari_gestiorapj`** a cada servidor.

Aquest usuari té les característiques següents:

- Pot executar ordres amb `sudo` sense necessitat de contrasenya, necessari perquè Ansible pugui instal·lar paquets i modificar configuracions del sistema.
- L'autenticació es fa exclusivament mitjançant **clau SSH**. No té contrasenya d'accés.
- La clau privada es troba a la màquina de control. Cap servidor no la conté.

## 2.1.3 Estructura de carpetes node de gestió Ansible

El node de gestió de Ansible serà una màquina interna al CPD que tindrà la següent estructura de carpetes i arxius per a aquesta gestió:

```
ansible-cpd/
├── inventory.ini
├── site.yml
├── group_vars/
│   └── all.yml                      ← variables compartidas (AMI, región, claves, etc.)
└── roles/
    ├── common/
    │   └── tasks/main.yml           ← tareas comunes a todos los servidores
    ├── ec2/
    │   ├── tasks/main.yml           ← creación de instancias EC2 en AWS
    │   └── vars/main.yml            ← variables específicas de EC2
    ├── nginx/
    │   ├── tasks/main.yml           ← instalación y configuración de Nginx
    │   ├── handlers/main.yml        ← handlers (restart/reload nginx)
    │   ├── templates/vhost.conf.j2  ← template del virtualhost
    │   └── vars/main.yml            ← variables específicas de Nginx
    ├── proftpd/
    │   ├── tasks/main.yml           ← instalación y configuración de ProFTPD (SFTP)
    │   ├── templates/proftpd.conf.j2← template configuración ProFTPD
    │   ├── templates/ldap.conf.j2   ← template integración LDAP
    │   └── vars/main.yml            ← variables específicas de ProFTPD
    ├── slapd/
    │   ├── tasks/main.yml           ← instalación y configuración de OpenLDAP
    │   ├── templates/base.ldif.j2   ← template estructura base LDAP
    │   ├── templates/usuarios.ldif.j2← template usuarios LDAP
    │   └── vars/main.yml            ← variables específicas de OpenLDAP
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

## 2.1.5 Preparació de l'entorn Ansible:

Desde aquesta màquina creada s'administraran i crearan les màquines del servidor web + sftp i LDAP

| <img src="../capturas/02-aws/CREACION-NODO-ANSIBLE.png" alt="captura1_ansible" width="500"> |
| :---: |
| Comanda de creació de la instància Node de Gestió Ansible |

| <img src="../capturas/02-aws/ASIGNACION-IP-FIJA-PUBLICA.png" alt="captura2_ansible" width="600"> |
| :---: |
| Assignació de ip pública a la màquina |
---
Accedim al node de gestió i preparem l'entorn:

| <img src="../capturas/02-aws/ESTRUCTURA-CARPETAS.png" alt="captura3_ansible" width="500"> |
| :---: |
| Estructura de carpetes creada |
---
### Configuració de credencials AWS al node de gestió
El primer que es farà es crear les instàncies tant del servei web + sftp com del LDAP amb un playbook.  
Abans de poder utilitzar Ansible per crear instàncies EC2 a AWS, cal configurar
les credencials d'accés al node de gestió. Com que s'utilitza AWS Academy,
les credencials (Access Key, Secret Key i Session Token) es generen
temporalment a cada sessió del Learner Lab i s'han de renovar cada cop que
es reinicia el laboratori.

Les credencials s'emmagatzemen al fitxer `~/.aws/credentials` del node de
gestió, que és el lloc estàndard on tant la CLI d'AWS com Ansible (a través
de boto3) van a buscar-les automàticament per autenticar-se contra l'API d'AWS.

Un cop configurades, Ansible podrà interactuar amb AWS per crear i configurar
les instàncies EC2 sense necessitat de introduir cap credencial manualment
durant l'execució dels playbooks.

| <img src="../capturas/02-aws/CREDENCIALES-CONFIGURADAS.png" alt="captura4_ansible" width="1000"> |
| :---: |
| Credencials configuradas al node de gestió |
---
### Creació de les dos instàncies amb Ansible

Per usar el mòdul amazon.aws d'Ansible necessites tenir instal·lada la col·lecció i la llibreria Python boto3:

| <img src="../capturas/02-aws/INSTALACION-BOTO3.png" alt="captura5_ansible" width="500"> |
| :---: |
| Instal·lació boto3 |

Ara els fitxers. Primer el group_vars/all.yml només amb el que necessitem per crear les màquines:

| <img src="../capturas/02-aws/VARIABLES_CREACIO_INSTANCIES.png" alt="captura6_ansible" width="500"> |
| :---: |
| Variables definides per a la creació d'instàncies |

Ara /vars/main.yml del rol on definirem les instàncies, el nom, el scurity group...:

| <img src="../capturas/02-aws/VARIABLES-ROL.png" alt="captura7_ansible" width="500"> |
| :---: |
| Definició de las instàncies a les variables del rol |

Ara el site.yml que és el playbook principal que actualment s’encarrega d’orquestrar la creació d’instàncies EC2 a AWS mitjançant el role ec2:

| <img src="../capturas/02-aws/SITE.png" alt="captura8_ansible" width="500"> |
| :---: |
| Configuració del site.yml |

Ara el inventory.ini que es divideix en dos fases la primera durant la creació de les instàncies que es treballarà en local  
i la segona fase on ja podrem omplir les dades del inevntari una vegada les màquines estiguin creades correctament:

| <img src="../capturas/02-aws/INVENTORY.png" alt="captura9_ansible" width="500"> |
| :---: |
| Configuració del inventory.ini |

Ara el tasks/main.yml del rol, que és on passa tot, en aquest cas deixo el playbook en format de text:

## EC2 Playbook (Ansible)

```yaml
---
---
# ─────────────────────────────────────
# CREAR INSTÀNCIES EC2
# ─────────────────────────────────────

- name: Crear instancias EC2
  amazon.aws.ec2_instance:

    name: "{{ item.name }}"
    region: "{{ aws_region }}"

    instance_type: "{{ item.type }}"
    image_id: "{{ aws_ami }}"

    key_name: "{{ aws_key_name }}"
    subnet_id: "{{ aws_subnet_id }}"

    security_groups: "{{ item.security_groups }}"

    tags: "{{ item.tags | combine({
      'Project': aws_tag_project,
      'Env': aws_tag_env
    }) }}"

    state: running
    wait: true

  loop: "{{ ec2_instancies }}"
  register: ec2_result


# ─────────────────────────────────────
# RESERVAR ELASTIC IP
# ─────────────────────────────────────

- name: Reservar Elastic IP
  amazon.aws.ec2_eip:
    region: "{{ aws_region }}"
    in_vpc: true
    state: present

  loop: "{{ ec2_result.results }}"
  register: eip_result


# ─────────────────────────────────────
# ASOCIAR ELASTIC IP
# ─────────────────────────────────────

- name: Asociar Elastic IP
  amazon.aws.ec2_eip:
    region: "{{ aws_region }}"
    device_id: "{{ item.0.instances[0].instance_id }}"
    public_ip: "{{ item.1.public_ip }}"
    in_vpc: true
    state: present

  loop: "{{ ec2_result.results | zip(eip_result.results) | list }}"


# ─────────────────────────────────────
# RESUMEN FINAL
# ─────────────────────────────────────

- name: Mostrar resumen de instancias creadas
  debug:
    msg: >
      {{ item.0.item.name }} → {{ item.1.public_ip }}

  loop: "{{ ec2_result.results | zip(eip_result.results) | list }}"

```

## Execució del playbook y verificació de que tot ha funcionat correctament:

Primer cal fer un ping per verificar que l'inventari esta responent:

| <img src="../capturas/02-aws/PINGINVENTARI.png" alt="captura10_ansible" width="500"> |
| :---: |
| Ping al inventari |

Ara desde el directori base d'ansible ja podem executar el playbook indicant el nom del arxiu site.yml:

<img src="../capturas/02-aws/EJECUCION1.png" alt="captura11_ansible" width="500">

<img src="../capturas/02-aws/EJECUCION2.png" alt="captura11_ansible" width="500">

| <img src="../capturas/02-aws/EJECUCION3.png" alt="captura11_ansible" width="700"> |
| :---: |
| Execució Playbook |
  

Captures de pantalla de verificació:

<img src="../capturas/02-aws/VERIFICACION1.png" alt="captura11_ansible" width="900">

<img src="../capturas/02-aws/VERIFICACION2.png" alt="captura11_ansible" width="400">

| <img src="../capturas/02-aws/VERIFICACION3.png" alt="captura11_ansible" width="700"> |
| :---: |
| Verificacions |
  
## Configuracions comuns als servidors

Ara es deixa completament preparat l'entorn realizant les següents tasques comuns als servidors:

- Creació d'usuari de gestió amb permisos d'administrador sense contrasenya
- Creació d'una clau per a que l'acces a les màquines sigui exclusivament per SSH sense contraenya.
- Instal·lació de rsyslog i enviament de logs al servidor que els centralitza

Primer cal editar el inventari, perque les màquines ja estan operatives i tenim les seves dades, també farem una agrupació al inventari per facilitar la gestió de tasques comuns:

| <img src="../capturas/02-aws/INVENTARI_ACTUALITZAT2.png" alt="captura12_ansible" width="500"> |
| :---: |
| Inventari actualitzat |

Generar la clau que es distribuira:

| <img src="../capturas/02-aws/GENERAR_CLAU.png" alt="captura13_ansible" width="500"> |
| :---: |
| Genreació de la clau |

Editar el fitxer de variables locals, afegim el nom del usuari que es crearà, el nom de la clau i on es copiarà, es copia automàticament al fitxer authorized_keys de l'usuari **`usuari_gestiorapj`** a cada servidor.  
Això permet que **`usuari_gestiorapj`** entri per SSH sense haver d'introduir cap contrasenya.:

| <img src="../capturas/02-aws/VARIABLES_COMUNS.png" alt="captura14_ansible" width="500"> |
| :---: |
| Fitxer group_vars/all.yml |

Editar el site.yml i afegir el següent:

| <img src="../capturas/02-aws/SITE_ACTUALITZAT.png" alt="captura15_ansible" width="500"> |
| :---: |
| Fitxer site.yml |

Editar el fitxer handler del rol per reiniciar serveis:

| <img src="../capturas/02-aws/HANDLERCOMUN.png" alt="captura15_ansible" width="500"> |
| :---: |
| Fitxer handlers/main.yml |

Utilitzarem el rol common hi ha que editar el tasks/main.yml del rol:

```yaml
---
# ── 1. Actualització del sistema ─────────────────────────────────────
- name: Actualitzar la llista i tots els paquets del sistema
  ansible.builtin.dnf:
    name: "*"
    state: latest
    update_cache: true

- name: Eliminar paquets i dependències obsoletes (Autoremove)
  ansible.builtin.dnf:
    autoremove: true

# ── 2. Crear usuari i fer que no necessiti contrasenya ─────────────────────────────────────
- name: Create user ansible
  ansible.builtin.user:
    name: "{{ created_username }}"
    shell: /bin/bash
    state: present
    create_home: yes

- name: Setup passwordless sudo for user ansible
  ansible.builtin.lineinfile:
    path: /etc/sudoers.d/90-cloud-init-users
    state: present
    line: "{{ created_username }} ALL=(ALL) NOPASSWD:ALL"
    insertafter: EOF

# ── 3. Distribuir i copiar la clau ─────────────────────────────────────
- name: Set authorized keys taken from url
  ansible.posix.authorized_key:
    user: "{{ created_username }}"
    state: present
    key: "{{ copy_local_key }}"

# ── 4. Canviar el Hostname del sistema ─────────────────────────────────────
- name: Configurar el hostname permanent de la màquina
  ansible.builtin.hostname:
    name: "{{ inventory_hostname | lower }}"

# ── 5. Instal·lació i configuració de Rsyslog ──────────────────────────────
- name: Assegurar que rsyslog està instal·lat
  ansible.builtin.dnf:
    name: rsyslog
    state: present

- name: Assegurar que el servei rsyslog està actiu i arrenca amb el sistema
  ansible.builtin.service:
    name: rsyslog
    state: started
    enabled: true

- name: Afegir la regla de reenviament al rsyslog.conf
  ansible.builtin.lineinfile:
    path: /etc/rsyslog.conf
    state: present
    line: '*.* @10.0.4.242:514;RSYSLOG_SyslogProtocol23Format'
    insertafter: EOF
  notify: Reiniciar rsyslog

- name: Forçar l'execució immediata del handler si hi ha hagut canvis
  ansible.builtin.meta: flush_handlers

- name: Enviar un log de prova
  ansible.builtin.command:
    cmd: 'logger -p syslog.info "Test log des de {{ ansible_facts[\"hostname\"] }}"'
```
## Execució del playbook y verificació de que tot ha funcionat correctament:

Primer cal fer un ping per verificar que l'inventari esta responent, auqesta vegada cal indicar la clau perquè son màquines remotes:

| <img src="../capturas/02-aws/PING_INVENTARI2.png" alt="captura16_ansible" width="500"> |
| :---: |
| Ping al inventari |

Ara desde el directori base d'ansible ja podem executar el playbook indicant el nom del arxiu site.yml:

| <img src="../capturas/02-aws/EXECUCIO_COMU.png" alt="captura17_ansible" width="500"> |
| :---: |
| Execució playbook |

Verificació de que tot ha funcionat correctament:

La connexió ssh amb la clau creada respon root tot esta correcte:

| <img src="../capturas/02-aws/VERIFICACIONCOMUN.png" alt="captura18_ansible" width="800"> |
| :---: |
| Verificació |

També verifiquem que s'ha canviat el hostname:

| <img src="../capturas/02-aws/VERIFICACIONHOSTNAMEWEB.png" alt="captura19_ansible" width="800"> |
| :---: |
| Verificació Hostname WEBFTP|

| <img src="../capturas/02-aws/VERIFICACIONHOSTNAMELADP.png" alt="captura19_ansible" width="800"> |
| :---: |
| Verificació Hostname LDAP|
### 2.2 02-aws/arquitectura.md

*Documento vacío.*

# 2.3 02-aws/ldap.md

Aquesta es una de les màquines que es gestiona amb amb ansible per lo que tota la configuració es fa desde el node de gestió mitjançant un playbook.

## Configuració feta amb Ansible

Primer de tot cal configurar una nova entrada en el nostre site.yml perquè associï el nostre servidor LDAP al rol de slapd:

| <img src="../capturas/02-aws/SRV-LDAP-GRUP2/SITEYML_LDAP.png" alt="CAPTURA1_LDAP" width="500"> |
| :---: |
| Confiuració site.yml |

Ara cal editar el fitxer de variables del rol en aquest cas roles/slapd/vars/main.yml, on definirem el domini i la llista de usuaris. A partir d'aquí, el playbook es pot executar tantes vegades com vulguis perquè utilitza un bucle dinàmic (loop) que s'adapta automàticament a la quantitat d'usuaris sense haver de modificar mai el codi de les tasques. A més, gràcies a la condició failed_when, Ansible detecta si un usuari ja s'havia creat en una execució anterior (Already exists), saltant-se els comptes vells de forma segura per centrar-se únicament a injectar els nous registres processats mitjançant les plantilles Jinja2. Això garanteix un sistema totalment idempotent, net i escalable per al teu entorn SFTP.

Arxiu en format de text:

```yaml
---
# Configuració del Domini LDAP
ldap_domain_dc: "dc=pro-ASIXcA1-grup2,dc=local"
ldap_organization: "Grup 2 - Projecte ASIX"
ldap_root_password: "pirineus"

# Llista d'exactament 4 usuaris per a SFTP
ldap_users:
  - username: "usuari_sftp1"
    cn: "Asier Hernandez"
    sn: "Hernandez"
    uid: 10001
    gid: 10001
    home: "/home/sftp/usuari_sftp1"
    shell: "/bin/bash"
    password: "{SHA}W6ph5Mm5Pz8GgiULbPgzG37mj9g=" # Hash de la contrasenya (grup2 a tots els usuaris)
    gecos: "Compte SFTP 1 - Asier"

  - username: "usuari_sftp2"
    cn: "Pablo Pineda"
    sn: "Pineda"
    uid: 10002
    gid: 10002
    home: "/home/sftp/usuari_sftp2"
    shell: "/bin/bash"
    password: "{SHA}W6ph5Mm5Pz8GgiULbPgzG37mj9g="
    gecos: "Compte SFTP 2 - Pablo"

  - username: "usuari_sftp3"
    cn: "Ronald Santana"
    sn: "Santana"
    uid: 10003
    gid: 10003
    home: "/home/sftp/usuari_sftp3"
    shell: "/bin/bash"
    password: "{SHA}W6ph5Mm5Pz8GgiULbPgzG37mj9g="
    gecos: "Compte SFTP 3 - Ronald"

  - username: "usuari_sftp4"
    cn: "Jair Godoy"
    sn: "Godoy"
    uid: 10004
    gid: 10004
    home: "/home/sftp/usuari_sftp4"
    shell: "/bin/bash"
    password: "{SHA}W6ph5Mm5Pz8GgiULbPgzG37mj9g="
    gecos: "Compte SFTP 4 - Godoy"
```

### Ara cal editar les plantilles jinja dels arxius ldif:

| <img src="../capturas/02-aws/SRV-LDAP-GRUP2/JINJA_BASE.png" alt="CAPTURA2_LDAP" width="300"> |
| :---: |
| roles/slapd/templates/base.ldif.j2 Plantilla Jinja2 per crear l'arrel del domini i les unitats organitzatives (ou=usuaris i ou=grups). |

| <img src="../capturas/02-aws/SRV-LDAP-GRUP2/JINJA_USUARIS.png" alt="CAPTURA3_LDAP" width="400"> |
| :---: |
| roles/slapd/templates/usuaris.ldif.j2 Plantilla Jinja2 genérica que es processarà un cop per cada usuari definit a la llista de variables, fent-los compatibles amb SFTP/Linux.|

Ara el playbook principal roles/slapd/tasks/main.yml que executa les accions realitzades al servidor remot. Playbook en format text:

```yaml
---
# ── 1. INSTAL·LACIÓ ───────────────────────────────────────────────────
- name: Instal·lar els paquets d'OpenLDAP i el servidor slapd
  ansible.builtin.dnf:
    name:
      - openldap
      - openldap-servers
      - openldap-clients
    state: present

- name: Assegurar que el servei slapd està actiu i arrenca amb el sistema
  ansible.builtin.service:
    name: slapd
    state: started
    enabled: true

# ── CONFIGURAR CREDENCIALS INTERNES DE CONFIG (MDB/HDB) ───────
- name: Generar el hash de la contrasenya del Manager per a la configuració interna
  ansible.builtin.command:
    cmd: "slappasswd -s '{{ ldap_root_password }}'"
  register: root_password_hash
  changed_when: false

- name: Configurar el Domini i la Contrasenya del Manager a OpenLDAP intern
  ansible.builtin.shell: |
    ldapmodify -Y EXTERNAL -H ldapi:/// <<EOF
    dn: olcDatabase={2}mdb,cn=config
    changetype: modify
    replace: olcSuffix
    olcSuffix: {{ ldap_domain_dc }}
    -
    replace: olcRootDN
    olcRootDN: cn=Manager,{{ ldap_domain_dc }}
    -
    replace: olcRootPW
    olcRootPW: {{ root_password_hash.stdout }}
    EOF
  register: config_result
  failed_when:
    - config_result.rc != 0
    - "'No such object' not in config_result.stderr"
  changed_when: config_result.rc == 0

# ── CARREGAR ESQUEMES DE LINUX (MOLT IMPORTANT) ───────────────
- name: Carregar els esquemes necessaris per a usuaris Linux (cosine, nis, inetorgperson)
  ansible.builtin.command:
    cmd: "ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/{{ item }}.ldif"
  loop:
    - cosine
    - nis
    - inetorgperson
  register: schema_result
  failed_when:
    - schema_result.rc != 0
    - "'Duplicate' not in schema_result.stderr"
    - "'Already exists' not in schema_result.stderr"
  changed_when: schema_result.rc == 0

# ── 2. PROCESAR E INJECTAR L'ESTRUCTURA BASE ────────────────────────
- name: Renderitzar l'estructura base des de la plantilla J2
  ansible.builtin.template:
    src: base.ldif.j2
    dest: /tmp/base.ldif
    mode: '0600'

- name: Cargar l'estructura base a OpenLDAP
  ansible.builtin.command:
    cmd: "ldapadd -x -w '{{ ldap_root_password }}' -D 'cn=Manager,{{ ldap_domain_dc }}' -f /tmp/base.ldif"
  register: base_result
  failed_when:
    - base_result.rc != 0
    - "'Already exists' not in base_result.stderr"

# ── 3. BUCLE PER PROCESAR E INJECTAR MÚLTIPLES USUARIS ─────────────
- name: Renderitzar la plantilla LDIF per a cada usuari de la llista
  ansible.builtin.template:
    src: usuarios.ldif.j2
    dest: "/tmp/{{ item.username }}.ldif"
    mode: '0600'
  loop: "{{ ldap_users }}"

- name: Cargar cada usuari a OpenLDAP de manera individual
  ansible.builtin.command:
    cmd: "ldapadd -x -w '{{ ldap_root_password }}' -D 'cn=Manager,{{ ldap_domain_dc }}' -f /tmp/{{ item.username }}.ldif"
  register: users_result
  failed_when:
    - users_result.rc != 0
    - "'Already exists' not in users_result.stderr"
  loop: "{{ ldap_users }}"
```
### Execució i verificacions:

<img src="../capturas/02-aws/SRV-LDAP-GRUP2/EJECUCION1.png" alt="CAPTURA4_LDAP" width="500">

| <img src="../capturas/02-aws/SRV-LDAP-GRUP2/EJECUCION2.png" alt="CAPTURA5_LDAP" width="900"> |
| :---: |
| Execució del playbook |

### Verificacions:

Ens conectem via ssh amb l'usuari de gestió i amb filtres ldapsearch mirem que tot s'ha creat correctament:

| <img src="../capturas/02-aws/SRV-LDAP-GRUP2/ESTRUCTURA_BASE.png" alt="CAPTURA6_LDAP" width="500"> |
| :---: |
| Estructura base |

<img src="../capturas/02-aws/SRV-LDAP-GRUP2/LLISTA_USUARIS.png" alt="CAPTURA7_LDAP" width="900">

| <img src="../capturas/02-aws/SRV-LDAP-GRUP2/LLISTA_USUARIS2.png" alt="CAPTURA8_LDAP" width="900"> |
| :---: |
| Llista d'Usuaris |

| <img src="../capturas/02-aws/SRV-LDAP-GRUP2/LLISTA_GRUPS.png" alt="CAPTURA9_LDAP" width="900"> |
| :---: |
| Llista de grups |

### 2.4 02-aws/logs-centralitzats.md

*Documento vacío.*

### 2.5 02-aws/usuaris-admin.md

*Documento vacío.*

### 2.6 02-aws/web-sftp.md

## 2.6.1 SFTPD

Servei sftpd

### Capturas 02-aws
- `capturas/02-aws/RED/VPC.png` — Diagrama de la VPC.
- `capturas/02-aws/RED/SUBNETPublica.png` — Subnet pública.
- `capturas/02-aws/RED/SUBNETPrivada.png` — Subnet privada.
- `capturas/02-aws/RED/IGW-Publico.png` — Gateway d'internet públic.
- `capturas/02-aws/RED/NAT-Privado.png` — NAT per a subnets privades.
- `capturas/02-aws/RED/TABLAPRIVADA.png` — Taula de rutes de la subnet privada.
- `capturas/02-aws/RED/ROUTEPUBLICA.png` — Regla de ruta pública.
- `capturas/02-aws/RED/ROUTENAT.png` — Regla de ruta NAT.
- `capturas/02-aws/SRV-ANSIBLE-GRUP2/SRV-ANS.png` — Captura del servidor Ansible.
- `capturas/02-aws/SRV-LDAP-GRUP2/SRV-LDAP.png` — Captura del servidor LDAP.
- `capturas/02-aws/SRV-BBDD-GRUP2/SRV-BBDD.png` — Captura del servidor de bases de dades.
- `capturas/02-aws/SRV-LOGS-GRUP2/SRV-LOGS.png` — Captura del servidor de logs.
- `capturas/02-aws/SRV-WEBFTP-GRUP2/CREACION1.png` — Procés de creació Web/SFTP, pas 1.
- `capturas/02-aws/SRV-WEBFTP-GRUP2/CREACION2.png` — Procés de creació Web/SFTP, pas 2.
- `capturas/02-aws/SRV-WEBFTP-GRUP2/CREACION3.png` — Procés de creació Web/SFTP, pas 3.
- `capturas/02-aws/SRV-WEBFTP-GRUP2/CREACION4.png` — Procés de creació Web/SFTP, pas 4.

![VPC](../capturas/02-aws/RED/VPC.png)
![Subnet pública](../capturas/02-aws/RED/SUBNETPublica.png)
![Subnet privada](../capturas/02-aws/RED/SUBNETPrivada.png)
![IGW públic](../capturas/02-aws/RED/IGW-Publico.png)
![NAT privat](../capturas/02-aws/RED/NAT-Privado.png)
![Taula privada](../capturas/02-aws/RED/TABLAPRIVADA.png)
![Ruta pública](../capturas/02-aws/RED/ROUTEPUBLICA.png)
![Ruta NAT](../capturas/02-aws/RED/ROUTENAT.png)

#### Servidors AWS
![Servidor Ansible](../capturas/02-aws/SRV-ANSIBLE-GRUP2/SRV-ANS.png)
![Servidor LDAP](../capturas/02-aws/SRV-LDAP-GRUP2/SRV-LDAP.png)
![Servidor BBDD](../capturas/02-aws/SRV-BBDD-GRUP2/SRV-BBDD.png)
![Servidor Logs](../capturas/02-aws/SRV-LOGS-GRUP2/SRV-LOGS.png)

#### Web / SFTP — procés de creació
![Creació 1](../capturas/02-aws/SRV-WEBFTP-GRUP2/CREACION1.png)
![Creació 2](../capturas/02-aws/SRV-WEBFTP-GRUP2/CREACION2.png)
![Creació 3](../capturas/02-aws/SRV-WEBFTP-GRUP2/CREACION3.png)
![Creació 4](../capturas/02-aws/SRV-WEBFTP-GRUP2/CREACION4.png)

Referència: [02-aws](02-aws)

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

# Model Entitat-Relació

## Introduccio

El següent model Entitat-Relació representa l'estructura de dades necessària per gestionar el sistema de comunicació interna d'InnovateTech. La base de dades emmagatzema informació sobre:

- Personal i organització: empleats i departaments.
- Comunicació: usuaris (interns i externs), trucades i configuració de qualitat.
- Streaming: catàleg de vídeos disponibles.
- Monitorització: proves d'amplada de banda realitzades pels operaris.
- Seguretat i auditoria: rols d'usuaris, control d'accés i registre d'avisos.

El model s'ha dissenyat seguint els requisits de l'apartat 3.2 i 3.3 de l'enunciat del projecte.

## Com hem creat el diagrama E/R (resum del procés)

### 7.2.1 Extracció de requisits

Vam llegir l’enunciat (apartats 3.2 i 3.3) i vam identificar 12 entitats amb els seus atributs, claus primàries i obligatorietat (NOT NULL). També vam detectar totes les relacions i els seus tipus (1:N, N:M, 0..1:1).

### 7.2.2 Disseny lògic

Vam dibuixar un esborrany inicial on vam:

- Assignar PK a cada entitat (codi, dni, id_usuari, nom_rol, etc.)
- Definir FK per a cada relació (p. ex., codi_departament a EMPLEAT)
- Resoldre la relació N:M entre USUARI i ROL mitjançant la taula associativa USUARI_ROL
- Establir cardinalitats explícites (ex: EMPLEAT → DEPARTAMENT és N:1; USUARI → EMPLEAT és 0..1:1)

### 7.2.3 Implementació al SGBD (MySQL)

Vam escriure un script SQL que crea totes les taules amb:

- PRIMARY KEY, FOREIGN KEY
- NOT NULL als atributs obligatoris
- UNIQUE a l’email d’usuari i al nom de departament
- CHECK per a valors (puntuació entre 1 i 5, durada >=0, etc.)
- Dades de prova significatives

### 7.2.4 Generació automàtica del diagrama

Vam executar l’script a la base de dades local i després vam fer servir l’eina Reverse Engineer del MySQL Workbench. Aquesta va llegir l’esquema i va dibuixar automàticament les taules, atributs i cla

### 7.2.5 Ajust manual i exportació

Vam reorganitzar les taules perquè fossin llegibles, vam verificar les cardinalitats (especialment la relació opcional USUARI-EMPLEAT) i vam exportar el diagrama 

| <img src="../../pro-ASIXC1A-grup2/capturas/07-bd/er-diagrama/RAPJ-E-R.png" alt="Captura-E-R" width="500"> |
| :---: |
| Diagrama Entitat Relacio |

### 7.3 07-bd/model-relacional.md

# Model relacional: transformació de l’E/R

## Introducció

Un cop vam tenir el diagrama Entitat-Relació complet (amb totes les entitats, atributs i cardinalitats), el següent pas va ser convertir-lo a un esquema relacional que es pogués implementar directament en un SGBD (en el nostre cas, MySQL). Aquesta transformació consisteix a:

1. Crear una taula per cada entitat.
2. Definir les claus primàries (PK) per identificar cada fila de manera única.
3. Establir les claus foranes (FK) per representar les relacions entre taules.

L’objectiu és obtenir un conjunt de sentències `CREATE TABLE` que respectin exactament el disseny lògic del diagrama.

## Com hem realitzat aquesta transformació

### 7.3.1 De cada entitat a una taula

Per cada entitat del diagrama E/R, vam crear una taula amb el mateix nom i els mateixos atributs, respectant els tipus de dades i les restriccions de `NULL` / `NOT NULL` que havíem definit.

- L’entitat `DEPARTAMENT` amb atributs `codi`, `nom`, `telefon` → taula `DEPARTAMENT` amb les mateixes columnes.

### 7.3.2 Assignació de claus primàries

Vam marcar com a `PRIMARY KEY` l’atribut o atributs que identifiquen de manera única cada fila:

- `codi` a `DEPARTAMENT`
- `dni` a `EMPLEAT`
- `id_usuari` a `USUARI`
- `nom_rol` a `ROL`
- etc.

Quan una relació N:M necessitava una taula associativa (com `USUARI_ROL`), vam definir una **clau primària composta** formada per les dues claus foranes.

### 7.3.3 Definició de claus foranes

Per a cada relació detectada en el diagrama E/R, vam afegir una `FOREIGN KEY` a la taula filla que referenciés la clau primària de la taula pare, indicant les accions `ON DELETE` i `ON UPDATE` (normalment `RESTRICT` i `CASCADE`).

**Exemples de relacions transformades a FK:**

- `EMPLEAT.codi_departament` → `DEPARTAMENT.codi`
- `USUARI.dni_empleat` → `EMPLEAT.dni`
- `USUARI_ROL.id_usuari` → `USUARI.id_usuari`
- `USUARI_ROL.nom_rol` → `ROL.nom_rol`
- `TRUCADA.usuari_originador` → `USUARI.id_usuari`
- `TRUCADA.usuari_destinatari` → `USUARI.id_usuari`
- `TRUCADA.id_grup_qualitat` → `GRUP_QUALITAT.id_grup`
- `MESURA_AMPLADA_BANDA.operari_id` → `USUARI.id_usuari`
- `AVIS.usuari_id` → `USUARI.id_usuari`

### 7.3.4 Generació del script SQL

Vam escriure un script complet (`InnovateTech.sql`) que conté totes les sentències `CREATE TABLE` en l’ordre correcte (primer les taules sense dependències, després les que tenen FK). Aquest script és l’evidència pràctica de la transformació al model relacional.

| <img src="../../../pro-ASIXc1A-grup2/pro-ASIXC1A-grup2/capturas/07-bd/er-diagrama/RAPJ-SQL.png" alt="Captura-E-R" width="500"> |
| :---: |
| SCRIP SQL MODEL RELACIONAL |


> Pots revisar el disseny complet de la base de dades en el [Script RAPJ.sql](../../pro-ASIXC1A-grup2/docs/07-bd/model-relacional.md).

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
