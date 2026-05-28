#!/bin/bash
# ============================================================
# Script: crear_usuari.sh (versió definitiva)
# ============================================================

# Funcions de validació
validar_dni() { [[ "$1" =~ ^[0-9]{8}[A-Z]$ ]]; }
validar_nie() { [[ "$1" =~ ^[XYZ][0-9]{7}[A-Z]$ ]]; }
validar_nom_usuari_mysql() { [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; }

# Comprovar email duplicat (utilitza usuari integracio)
email_existeix() {
    local email=$1
    local count=$(mysql -u integracio -ppirineus -h 32.197.67.184 --ssl=0 InnovateTech -sN -e "SELECT COUNT(*) FROM USUARI WHERE email='$email';" 2>/dev/null)
    echo "$count"
}

# Generar email únic
generar_email_unic() {
    local base="$1"
    local email="$base"
    local i=1
    while [[ $(email_existeix "$email") -gt 0 ]]; do
        if [[ "$base" == *"@"* ]]; then
            local local_part="${base%@*}"
            local domain="${base#*@}"
            email="${local_part}${i}@${domain}"
        else
            email="${base}${i}"
        fi
        i=$((i+1))
    done
    echo "$email"
}

# ========== 1. Nom d'usuari MySQL ==========
while true; do
    read -p "Nom d'usuari MySQL (ex: juan_perez): " USUARI_MYSQL
    if [[ -z "$USUARI_MYSQL" ]]; then
        echo "❌ Error: El nom no pot estar buit."
    elif ! validar_nom_usuari_mysql "$USUARI_MYSQL"; then
        echo "❌ Error: Nom ha de començar per lletra o '_', només lletres, números i '_'."
    elif sudo mysql -u root -p -sN -e "SELECT 1 FROM mysql.user WHERE user='$USUARI_MYSQL'" 2>/dev/null | grep -q 1; then
        echo "❌ Error: L'usuari '$USUARI_MYSQL' ja existeix."
    else
        break
    fi
done

# ========== 2. Contrasenya MySQL ==========
while true; do
    read -s -p "Contrasenya per a $USUARI_MYSQL (mínim 8): " PASS
    echo
    read -s -p "Torna a escriure: " PASS2
    echo
    if [[ ${#PASS} -lt 8 ]]; then
        echo "❌ Error: Mínim 8 caràcters."
    elif [ "$PASS" != "$PASS2" ]; then
        echo "❌ Error: No coincideixen."
    else
        break
    fi
done

# ========== 3. Contrasenya web ==========
while true; do
    read -s -p "Contrasenya aplicació web (mínim 6): " PASS_WEB
    echo
    read -s -p "Torna a escriure: " PASS_WEB2
    echo
    if [[ ${#PASS_WEB} -lt 6 ]]; then
        echo "❌ Error: Mínim 6 caràcters."
    elif [ "$PASS_WEB" != "$PASS_WEB2" ]; then
        echo "❌ Error: No coincideixen."
    else
        break
    fi
done

# Generar hash bcrypt
PASS_WEB_HASH=$(php -r "echo password_hash('$PASS_WEB', PASSWORD_DEFAULT);" 2>/dev/null)
if [[ -z "$PASS_WEB_HASH" ]]; then
    echo "❌ Error: Instal·la php-cli: sudo dnf install php-cli (o apt install php-cli)"
    exit 1
fi

# ========== 4. Tipus d'usuari ==========
echo "Tipus d'usuari:"
select TIPUS in "Intern (empleat)" "Extern (client)"; do
    case $TIPUS in
        "Intern (empleat)") TIPUS_BD="intern"; break;;
        "Extern (client)")  TIPUS_BD="extern"; break;;
    esac
done

# ========== 5. Recollir dades segons tipus ==========
if [ "$TIPUS_BD" = "intern" ]; then
    echo "--- Dades de l'empleat ---"
    while true; do
        read -p "DNI (8 números + lletra) o NIE (X/Y/Z + 7 números + lletra): " DNI_NIE
        if validar_dni "$DNI_NIE" || validar_nie "$DNI_NIE"; then
            existeix=$(mysql -u integracio -ppirineus -h 32.197.67.184 --ssl=0 InnovateTech -sN -e "SELECT COUNT(*) FROM EMPLEAT WHERE dni='$DNI_NIE';" 2>/dev/null)
            if [[ "$existeix" -gt 0 ]]; then
                echo "❌ Error: El DNI/NIE '$DNI_NIE' ja està registrat."
            else
                break
            fi
        else
            echo "❌ Error: Format incorrecte. Ex: 12345678A o X1234567A"
        fi
    done
    read -p "Nom: " NOM
    read -p "Cognoms: " COGNOMS
    read -p "Adreça (opcional): " ADRECA
    read -p "Telèfon (opcional): " TELEFON_EMP
    echo "Departaments disponibles:"
    mysql -u integracio -ppirineus -h 32.197.67.184 --ssl=0 -e "SELECT codi, nom FROM InnovateTech.DEPARTAMENT;" 2>/dev/null
    while true; do
        read -p "Codi del departament: " CODI_DEPT
        if [[ "$CODI_DEPT" =~ ^[0-9]+$ ]]; then
            break
        else
            echo "❌ Error: Introdueix un codi numèric."
        fi
    done
    EMAIL_BASE=$(echo "${NOM}.${COGNOMS}" | tr '[:upper:]' '[:lower:]' | tr -d ' ' | sed 's/[^a-z0-9.]//g')"@innovatech.com"
    EMAIL=$(generar_email_unic "$EMAIL_BASE")
    echo "Email generat: $EMAIL"
    EXTENSIO=$(shuf -i 100-999 -n 1)
    ESTAT="actiu"

    # ========== 6. Rols (només per interns) ==========
    while true; do
        read -p "Rol(s) (admin, vendes, administracio, treballador) separats per comes: " ROLS_INPUT
        ROLS_INPUT_CLEAN=$(echo "$ROLS_INPUT" | tr -d ' ')
        IFS=',' read -ra ROLS <<< "$ROLS_INPUT_CLEAN"
        ROLS_VALIDS=("admin" "vendes" "administracio" "treballador")
        INVALID=0
        for ROL in "${ROLS[@]}"; do
            if [[ ! " ${ROLS_VALIDS[@]} " =~ " ${ROL} " ]]; then
                echo "❌ Error: Rol '$ROL' no vàlid."
                INVALID=1
                break
            fi
        done
        if [[ $INVALID -eq 0 ]]; then
            break
        fi
    done
else
    echo "--- Dades del client extern ---"
    read -p "Nom complet: " NOM_COMPLET
    read -p "Email base: " EMAIL_BASE
    EMAIL=$(generar_email_unic "$EMAIL_BASE")
    echo "Email final: $EMAIL"
    read -p "Telèfon (opcional): " TELEFON_EXT
    ESTAT="actiu"
    # Els externs no tenen DNI, departament, extensió ni rols
    DNI_NIE="NULL"
    CODI_DEPT="NULL"
    EXTENSIO="NULL"
fi

# ========== 7. Generar fitxer SQL ==========
OUTPUT="${USUARI_MYSQL}_creacio_completa.sql"
echo "-- Script generat el $(date)" > "$OUTPUT"
echo "USE InnovateTech;" >> "$OUTPUT"

if [ "$TIPUS_BD" = "intern" ]; then
    cat >> "$OUTPUT" <<EOF
INSERT INTO EMPLEAT (dni, nom, cognoms, adreça, telefon, codi_departament)
VALUES ('$DNI_NIE', '$NOM', '$COGNOMS', '$ADRECA', '$TELEFON_EMP', $CODI_DEPT);

INSERT INTO USUARI (nom_complet, email, extensio_identificador, estat, tipus, dni_empleat)
VALUES ('$NOM $COGNOMS', '$EMAIL', '$EXTENSIO', '$ESTAT', '$TIPUS_BD', '$DNI_NIE');

EOF
else
    cat >> "$OUTPUT" <<EOF
INSERT INTO USUARI (nom_complet, email, extensio_identificador, estat, tipus, dni_empleat)
VALUES ('$NOM_COMPLET', '$EMAIL', NULL, '$ESTAT', '$TIPUS_BD', NULL);

EOF
fi

echo "SET @id_usuari = LAST_INSERT_ID();" >> "$OUTPUT"

# Assignar rols només si és intern
if [ "$TIPUS_BD" = "intern" ]; then
    for ROL in "${ROLS[@]}"; do
        echo "INSERT INTO USUARI_ROL (id_usuari, nom_rol) VALUES (@id_usuari, '$ROL');" >> "$OUTPUT"
    done
fi

# Contrasenya web
echo "INSERT INTO CONTRASENYES (usuari_id, hash_contrasenya, data_creacio, activa) VALUES (@id_usuari, '$PASS_WEB_HASH', NOW(), TRUE);" >> "$OUTPUT"

# Usuari MySQL i permisos
echo "" >> "$OUTPUT"
echo "CREATE USER IF NOT EXISTS '$USUARI_MYSQL'@'%' IDENTIFIED BY '$PASS';" >> "$OUTPUT"

declare -A GRANTS_AFEGITS
afegir_grant() {
    local grant="$1"
    if [[ -z "${GRANTS_AFEGITS[$grant]}" ]]; then
        echo "$grant" >> "$OUTPUT"
        GRANTS_AFEGITS[$grant]=1
    fi
}

if [ "$TIPUS_BD" = "intern" ]; then
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
fi
afegir_grant "GRANT FILE ON *.* TO '$USUARI_MYSQL'@'%';"
echo "FLUSH PRIVILEGES;" >> "$OUTPUT"

# ========== 8. Execució ==========
echo "✅ Fitxer $OUTPUT generat."
read -p "Vols executar-lo ara? (s/n): " EXECUTAR
if [[ "$EXECUTAR" =~ ^[Ss]$ ]]; then
    if sudo mysql -u root -p < "$OUTPUT"; then
        echo "✅ Usuari $USUARI_MYSQL creat correctament."
        echo "🔌 Connexió BD: mysql -u $USUARI_MYSQL -p -h localhost InnovateTech"
        echo "🌐 Login web: $EMAIL / $PASS_WEB"
    else
        echo "❌ Error en executar $OUTPUT. Revisa el fitxer."
    fi
else
    echo "Executa manualment: sudo mysql -u root -p < $OUTPUT"
fi
