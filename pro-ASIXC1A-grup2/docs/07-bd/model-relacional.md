# Model relacional: transformació de l’E/R

## Introducció

Un cop vam tenir el diagrama Entitat-Relació complet (amb totes les entitats, atributs i cardinalitats), el següent pas va ser convertir-lo a un esquema relacional que es pogués implementar directament en un SGBD (en el nostre cas, MySQL). Aquesta transformació consisteix a:

1. Crear una taula per cada entitat.
2. Definir les claus primàries (PK) per identificar cada fila de manera única.
3. Establir les claus foranes (FK) per representar les relacions entre taules.

L’objectiu és obtenir un conjunt de sentències `CREATE TABLE` que respectin exactament el disseny lògic del diagrama.

## Com hem realitzat aquesta transformació

### 1. De cada entitat a una taula

Per cada entitat del diagrama E/R, vam crear una taula amb el mateix nom i els mateixos atributs, respectant els tipus de dades i les restriccions de `NULL` / `NOT NULL` que havíem definit.

- L’entitat `DEPARTAMENT` amb atributs `codi`, `nom`, `telefon` → taula `DEPARTAMENT` amb les mateixes columnes.

### 2. Assignació de claus primàries

Vam marcar com a `PRIMARY KEY` l’atribut o atributs que identifiquen de manera única cada fila:

- `codi` a `DEPARTAMENT`
- `dni` a `EMPLEAT`
- `id_usuari` a `USUARI`
- `nom_rol` a `ROL`
- etc.

Quan una relació N:M necessitava una taula associativa (com `USUARI_ROL`), vam definir una **clau primària composta** formada per les dues claus foranes.

### 3. Definició de claus foranes

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

### 4. Generació del script SQL

Vam escriure un script complet (`InnovateTech.sql`) que conté totes les sentències `CREATE TABLE` en l’ordre correcte (primer les taules sense dependències, després les que tenen FK). Aquest script és l’evidència pràctica de la transformació al model relacional.

> Pots revisar el disseny complet de la base de dades en el [Script RAPJ.sql](../07-bd/RAPJ.sql).