#!/bin/bash
# ============================================================
# monitor_video_unico.sh
# - Insereix vídeos nous només quan el .meta té dades.
# - Evita duplicats comprovant la BD abans d'inserir.
# - Esborra de la BD quan s'elimina un vídeo.
# - Actualitza metadades si es modifica el .meta.
# ============================================================

BD_HOST="32.197.67.184"
BD_USER="integracio"
BD_PASS="pirineus"
BD_NAME="InnovateTech"
VIDEO_DIR="/var/www/html/videos"
BASE_URL="https://23.23.53.151/videos"

MYSQL_OPTS="-u $BD_USER -p$BD_PASS -h $BD_HOST $BD_NAME"

# Comprova si un vídeo ja existeix a la BD (pel títol o per l'enllaç)
video_existeix() {
    local title="$1"
    local url="$2"
    local count=$(mysql $MYSQL_OPTS -sN -e "SELECT COUNT(*) FROM VIDEO WHERE titol='$title' OR enllac_streaming='$url';")
    echo "$count"
}

processar_video() {
    local video_file="$1"
    local filename=$(basename "$video_file")
    local title="${filename%.*}"
    local url="$BASE_URL/$filename"
    local data_pub=$(date '+%Y-%m-%d')
    local durada=0
    local meta_file="${video_file}.meta"

    # Obtenir durada
    if command -v ffprobe &> /dev/null; then
        durada=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$video_file" 2>/dev/null | cut -d. -f1)
        [ -z "$durada" ] && durada=0
    fi

    # Llegir metadades del .meta
    local desc=""
    local cat=""
    if [ -f "$meta_file" ] && [ -s "$meta_file" ]; then
        local content=$(grep -v '^#' "$meta_file" | grep -v '^[[:space:]]*$')
        if [ -n "$content" ]; then
            if echo "$content" | grep -q "descripcio="; then
                desc=$(echo "$content" | grep -oP 'descripcio=\K.*' | head -1)
                cat=$(echo "$content" | grep -oP 'categoria=\K.*' | head -1)
            else
                desc=$(echo "$content" | sed -n '1p')
                cat=$(echo "$content" | sed -n '2p')
            fi
            desc=$(echo "$desc" | sed "s/'/\\'/g")
            cat=$(echo "$cat" | sed "s/'/\\'/g")
        else
            echo "$(date) ⏳ $filename: .meta buit, esperant edició"
            return
        fi
    else
        # Crear .meta buit si no existeix
        cat > "$meta_file" <<EOF
# Descripció (primera línia)
# Categoria (segona línia)
EOF
        echo "$(date) 📝 Creat fitxer de metadades per a $filename. Edita'l i guarda'l perquè s'insereixi a la BD."
        return
    fi

    # Evitar duplicats
    if [ "$(video_existeix "$title" "$url")" -gt 0 ]; then
        echo "$(date) ⚠️ $filename ja existeix a la BD. No s'insereix."
        return
    fi

    # Inserir
    mysql $MYSQL_OPTS <<EOF
INSERT INTO VIDEO (titol, descripcio, categoria, durada, data_publicacio, enllac_streaming)
VALUES ('$title', '$desc', '$cat', $durada, '$data_pub', '$url');
EOF
    if [ $? -eq 0 ]; then
        echo "$(date) ✅ Inserit: $filename (desc='$desc', cat='$cat')"
    else
        echo "$(date) ❌ Error en inserir $filename"
    fi
}

esborrar_video() {
    local file="$1"
    local filename=$(basename "$file")
    local url="$BASE_URL/$filename"
    mysql $MYSQL_OPTS -e "DELETE FROM VIDEO WHERE enllac_streaming = '$url';"
    [ $? -eq 0 ] && echo "$(date) 🗑️ Esborrat de BD: $filename" || echo "$(date) ❌ Error esborrant $filename"
}

actualitzar_metadades() {
    local meta_file="$1"
    local video_file="${meta_file%.meta}"
    if [ -f "$video_file" ]; then
        processar_video "$video_file"   # reprocessa (actualitza)
    fi
}

# Comprovar directori
[ ! -d "$VIDEO_DIR" ] && { echo "Error: $VIDEO_DIR no existeix"; exit 1; }

echo "Monitoritzant $VIDEO_DIR (un sol script)..."
inotifywait -m -r -e create -e modify -e delete --format '%e %w%f' "$VIDEO_DIR" | while read event filepath; do
    case "$event" in
        CREATE|MOVED_TO)
            if [[ "$filepath" =~ \.(mp4|mkv|avi|mov|webm)$ ]]; then
                processar_video "$filepath"
            fi
            ;;
        MODIFY)
            if [[ "$filepath" == *.meta ]]; then
                actualitzar_metadades "$filepath"
            fi
            ;;
        DELETE)
            if [[ "$filepath" =~ \.(mp4|mkv|avi|mov|webm)$ ]]; then
                esborrar_video "$filepath"
            fi
            ;;
    esac
done
Tu, Ahir 12:29

