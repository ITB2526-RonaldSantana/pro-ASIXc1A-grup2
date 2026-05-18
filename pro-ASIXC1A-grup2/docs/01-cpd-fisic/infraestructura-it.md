# Infraestructura IT

## Servidors

El CPD disposa de **4 servidors** instal·lats al Rack 1, cadascun dedicat a un servei específic (sense AMIs preconfigurades del marketplace d'AWS):

| Servidor | Servei | Instància AWS |
|---|---|---|
| Servidor 1 | Servei web (Apache/Nginx) + SFTP (OpenSSH autenticat via LDAP) | EC2 t3.small |
| Servidor 2 | Directori actiu LDAP (OpenLDAP / Samba AD) + Centralització de logs (Graylog / ELK) | EC2 t3.small |
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
