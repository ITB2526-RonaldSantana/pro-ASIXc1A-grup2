#!/bin/bash
# ============================================================
# Script: crear_usuari_complet.sh
# Descripció:
#   - Crea usuari MySQL amb privilegis (GRANT FILE inclòs)
#   - Insereix dades a EMPLEAT, USUARI, USUARI_ROL i CONTRASENYES
#   - Suporta usuaris interns (amb DNI, departament) i externs
#   - Genera un fitxer .sql amb totes les operacions
# ============================================================

# ----------------------------
# 1. Dades de l'usuari MySQL (accés a la BD)
# ----------------------------
read -p "Nom d'usuari MySQL (ex: juan_perez): " USUARI_MYSQL
while [[ -z "$USUARI_MYSQL" ]]; do
    echo "Error: El nom d'usuari no pot estar buit."
    read -p "Nom d'usuari MySQL: " USUARI_MYSQL
done

read -s -p "Contrasenya per a $USUARI_MYSQL (accés a la BD): " PASS
echo
read -s -p "Torna a escriure la contrasenya: " PASS2
echo
if [ "$PASS" != "$PASS2" ]; then
    echo "Error: Les contrasenyes no coincideixen."
    exit 1
fi

# ----------------------------
# 2. Contrasenya per a l'aplicació web (login)
# ----------------------------
echo
read -s -p "Contrasenya per a l'aplicació web (login per email): " PASS_WEB
echo
read -s -p "Torna a escriure la contrasenya web: " PASS_WEB2
echo
if [ "$PASS_WEB" != "$PASS_WEB2" ]; then
    echo "Error: Les contrasenyes web no coincideixen."
    exit 1
fi

# Generar hash bcrypt amb PHP (compatible amb password_verify a l'aplicació web)
PASS_WEB_HASH=$(PASS_WEB_ENV="$PASS_WEB" php -r 'echo password_hash(getenv("PASS_WEB_ENV"), PASSWORD_DEFAULT);' 2>/dev/null)
if [[ -z "$PASS_WEB_HASH" ]]; then
    echo "Error: No s'ha pogut generar el hash de la contrasenya. Verifica que PHP estigui instal·lat."
    exit 3
fi

# ----------------------------
# 3. Tipus d'usuari (intern/extern)
# ----------------------------
echo "Tipus d'usuari:"
select TIPUS in "Intern (empleat)" "Extern (client)"; do
    case $TIPUS in
        "Intern (empleat)") TIPUS_BD="intern"; break;;
        "Extern (client)") TIPUS_BD="extern"; break;;
    esac
done

# ----------------------------
# 4. Rols (un o més separats per comes)
# ----------------------------
read -p "Rol(s) (admin, vendes, administracio, treballador) separats per comes: " ROLS_INPUT
ROLS_INPUT_CLEAN=$(echo "$ROLS_INPUT" | tr -d ' ')
IFS=',' read -ra ROLS <<< "$ROLS_INPUT_CLEAN"
ROLS_VALIDS=("admin" "vendes" "administracio" "treballador")
for ROL in "${ROLS[@]}"; do
    if [[ ! " ${ROLS_VALIDS[@]} " =~ " ${ROL} " ]]; then
        echo "Error: Rol '$ROL' no vàlid."
        exit 2
    fi
done

# ----------------------------
# 5. Recollir dades segons tipus
# ----------------------------
if [ "$TIPUS_BD" = "intern" ]; then
    echo "--- Dades de l'empleat (intern) ---"
    read -p "DNI (format 12345678A): " DNI
    read -p "Nom: " NOM
    read -p "Cognoms: " COGNOMS
    read -p "Adreça (opcional): " ADRECA
    read -p "Telèfon (opcional): " TELEFON_EMP
    echo "Departaments disponibles:"
    sudo mysql -u root -p -e "SELECT codi, nom FROM InnovateTech.DEPARTAMENT;"
    read -p "Codi del departament: " CODI_DEPT
    # Generar email automàtic (nom.cognoms@innovatech.com)
    EMAIL=$(echo "${NOM}.${COGNOMS}" | tr '[:upper:]' '[:lower:]' | tr -d ' ' | sed 's/[^a-z0-9.]//g')"@innovatech.com"
    echo "Email generat: $EMAIL"
    EXTENSIO=$(shuf -i 100-999 -n 1)
    ESTAT="actiu"
else
    echo "--- Dades del client extern ---"
    read -p "Nom complet: " NOM_COMPLET
    read -p "Email: " EMAIL
    EXTENSIO="NULL"
    ESTAT="actiu"
    DNI="NULL"
    CODI_DEPT="NULL"
fi

# ----------------------------
# 6. Generar fitxer SQL
# ----------------------------
OUTPUT="${USUARI_MYSQL}_creacio_completa.sql"
echo "-- Script generat per crear_usuari_complet.sh el $(date)" > "$OUTPUT"
echo "USE InnovateTech;" >> "$OUTPUT"

# 6a. Crear empleat si és intern
if [ "$TIPUS_BD" = "intern" ]; then
    cat >> "$OUTPUT" <<EOF
INSERT INTO EMPLEAT (dni, nom, cognoms, adreça, telefon, codi_departament)
VALUES ('$DNI', '$NOM', '$COGNOMS', '$ADRECA', '$TELEFON_EMP', $CODI_DEPT);

EOF
fi

# 6b. Crear usuari (taula USUARI)
if [ "$TIPUS_BD" = "intern" ]; then
    cat >> "$OUTPUT" <<EOF
INSERT INTO USUARI (nom_complet, email, extensio_identificador, estat, tipus, dni_empleat)
VALUES ('$NOM $COGNOMS', '$EMAIL', '$EXTENSIO', '$ESTAT', '$TIPUS_BD', '$DNI');

EOF
else
    cat >> "$OUTPUT" <<EOF
INSERT INTO USUARI (nom_complet, email, extensio_identificador, estat, tipus, dni_empleat)
VALUES ('$NOM_COMPLET', '$EMAIL', NULL, '$ESTAT', '$TIPUS_BD', NULL);

EOF
fi

# 6c. Obtenir l'id_usuari
echo "SET @id_usuari = LAST_INSERT_ID();" >> "$OUTPUT"

# 6d. Assignar rols a USUARI_ROL
for ROL in "${ROLS[@]}"; do
    echo "INSERT INTO USUARI_ROL (id_usuari, nom_rol) VALUES (@id_usuari, '$ROL');" >> "$OUTPUT"
done

# 6e. Inserir contrasenya web a la taula CONTRASENYES
echo "-- Inserir contrasenya per a l'aplicació web" >> "$OUTPUT"
echo "INSERT INTO CONTRASENYES (usuari_id, hash_contrasenya, data_creacio, activa) VALUES (@id_usuari, '$PASS_WEB_HASH', NOW(), TRUE);" >> "$OUTPUT"

# 6f. Crear usuari MySQL i assignar permisos
echo "" >> "$OUTPUT"
echo "-- Creació de l'usuari MySQL i permisos" >> "$OUTPUT"
echo "CREATE USER IF NOT EXISTS '$USUARI_MYSQL'@'%' IDENTIFIED BY '$PASS';" >> "$OUTPUT"

# Acumular privilegis segons els rols
declare -A GRANTS_AFEGITS
afegir_grant() {
    local grant="$1"
    if [[ -z "${GRANTS_AFEGITS[$grant]}" ]]; then
        echo "$grant" >> "$OUTPUT"
        GRANTS_AFEGITS[$grant]=1
    fi
}

for ROL in "${ROLS[@]}"; do
    case $ROL in
        admin)
            afegir_grant "GRANT ALL PRIVILEGES ON InnovateTech.* TO '$USUARI_MYSQL'@'%' WITH GRANT OPTION;"
            ;;
        vendes)
            afegir_grant "GRANT SELECT, INSERT, UPDATE ON InnovateTech.TRUCADA TO '$USUARI_MYSQL'@'%';"
            afegir_grant "GRANT SELECT ON InnovateTech.USUARI TO '$USUARI_MYSQL'@'%';"
            ;;
        administracio)
            afegir_grant "GRANT SELECT, INSERT, UPDATE ON InnovateTech.EMPLEAT TO '$USUARI_MYSQL'@'%';"
            afegir_grant "GRANT SELECT, INSERT, UPDATE ON InnovateTech.DEPARTAMENT TO '$USUARI_MYSQL'@'%';"
            ;;
        treballador)
            afegir_grant "GRANT SELECT ON InnovateTech.VIDEO TO '$USUARI_MYSQL'@'%';"
            afegir_grant "GRANT SELECT ON InnovateTech.CONFIGURACIO_SERVIDOR TO '$USUARI_MYSQL'@'%';"
            afegir_grant "GRANT INSERT ON InnovateTech.TRUCADA TO '$USUARI_MYSQL'@'%';"
            ;;
    esac
done
afegir_grant "GRANT FILE ON *.* TO '$USUARI_MYSQL'@'%';"

echo "FLUSH PRIVILEGES;" >> "$OUTPUT"

# ----------------------------
# 7. Execució (opcional)
# ----------------------------
echo "✅ Fitxer $OUTPUT generat. La contrasenya web s'ha guardat com a hash bcrypt (compatible amb l'aplicació web)."
read -p "Vols executar-lo ara? (s/n): " EXECUTAR
if [[ "$EXECUTAR" =~ ^[Ss]$ ]]; then
    if sudo mysql -u root -p < "$OUTPUT"; then
        echo "✅ Usuari $USUARI_MYSQL creat, dades inserides i permisos assignats."
        echo "🔌 Connecta't a la BD: mysql -u $USUARI_MYSQL -p -h localhost InnovateTech"
        echo "🌐 Per login a l'aplicació web, usa l'email $EMAIL i la contrasenya web que has definit."
    else
        echo "❌ Error en executar $OUTPUT. Revisa les dades i la connexió."
    fi
else
    echo "Executa manualment: sudo mysql -u root -p < $OUTPUT"
fi