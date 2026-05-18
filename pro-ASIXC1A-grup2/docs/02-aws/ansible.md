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
