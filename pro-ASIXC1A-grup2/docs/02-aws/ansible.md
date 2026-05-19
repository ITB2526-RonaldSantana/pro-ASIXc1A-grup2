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

El node de gestió de Ansible serà una màquina interna al CPD que tindrà la següent estructura de carpetes i arxius per a aquesta gestió:

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

## 2.1.5 Captures de pantalla de la preparació de l'entorn Ansible:

| <img src="" alt="captura1_ansible" width="500"> |
| :---: |
| Creació estructura de carpetes, fitxers i assignació de permisos |