#!/bin/bash
# ======================================================
# backup_setmanal.sh
# Realitza un backup complet de la BD InnovateTech
# ======================================================

BACKUP_DIR="/home/PPM/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/InnovateTech_$TIMESTAMP.sql"

# Crear directori si no existeix
mkdir -p "$BACKUP_DIR"

# Executar mysqldump (sense contrasenya en línia d'ordres, demanarà interactiva)
# Si vols automatitzar, crea un fitxer .my.cnf a la carpeta de l'usuari.
mysqldump -u root -p --databases InnovateTech --routines --triggers --events > "$BACKUP_FILE"

# Comprovar si l'última ordre va funcionar
if [ $? -eq 0 ]; then
    echo "$(date) ✅ Backup complet: $BACKUP_FILE" >> /home/PPM/backup.log
    # Mantenir només els últims 5 backups
    ls -tp "$BACKUP_DIR"/InnovateTech_*.sql | tail -n +6 | xargs -I {} rm -- {} 2>/dev/null
else
    echo "$(date) ❌ Error en el backup" >> /home/PPM/backup.log
fi
[PPM@srv-bdd-grup2 ~]$
