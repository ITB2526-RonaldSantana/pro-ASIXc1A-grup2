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
