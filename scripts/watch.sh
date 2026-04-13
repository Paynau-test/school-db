#!/bin/bash
# ============================================
# Hot reload for SQL files
# Watches for changes in migrations/ and
# stored-procedures/ and auto-applies them.
#
# Requires: fswatch (macOS) or inotifywait (Linux)
# macOS:  brew install fswatch
# Linux:  apt install inotify-tools
# ============================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN} school-db · Hot Reload active${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "${YELLOW}Watching: migrations/ stored-procedures/${NC}"
echo -e "${YELLOW}Edit any .sql file and it auto-applies.${NC}"
echo -e "${YELLOW}Ctrl+C to stop.${NC}"
echo ""

# Detect available watch tool
if command -v fswatch &> /dev/null; then
    # macOS (fswatch)
    fswatch -0 -e ".*" -i "\\.sql$" migrations/ stored-procedures/ | while read -d "" file; do
        echo ""
        echo -e "${CYAN}[$(date +%H:%M:%S)] Change detected: ${file}${NC}"
        bash "$SCRIPT_DIR/apply.sh" "$file"
        echo -e "${GREEN}[$(date +%H:%M:%S)] Done. Waiting for changes...${NC}"
    done

elif command -v inotifywait &> /dev/null; then
    # Linux (inotify-tools)
    inotifywait -m -r -e modify,create --format '%w%f' migrations/ stored-procedures/ | while read file; do
        if [[ "$file" == *.sql ]]; then
            echo ""
            echo -e "${CYAN}[$(date +%H:%M:%S)] Change detected: ${file}${NC}"
            bash "$SCRIPT_DIR/apply.sh" "$file"
            echo -e "${GREEN}[$(date +%H:%M:%S)] Done. Waiting for changes...${NC}"
        fi
    done

else
    # Fallback: polling every 2 seconds
    echo -e "${YELLOW}[!] fswatch/inotifywait not found.${NC}"
    echo -e "${YELLOW}    Using polling (every 2s). For better performance:${NC}"
    echo -e "${YELLOW}    macOS: brew install fswatch${NC}"
    echo -e "${YELLOW}    Linux: apt install inotify-tools${NC}"
    echo ""

    declare -A CHECKSUMS

    compute_checksum() {
        if command -v md5sum &> /dev/null; then
            md5sum "$1" | cut -d' ' -f1
        else
            md5 -q "$1"
        fi
    }

    # Initialize checksums
    for f in migrations/*.sql stored-procedures/*.sql; do
        [ -f "$f" ] && CHECKSUMS["$f"]="$(compute_checksum "$f")"
    done

    while true; do
        for f in migrations/*.sql stored-procedures/*.sql; do
            [ -f "$f" ] || continue
            new_checksum="$(compute_checksum "$f")"
            if [ "${CHECKSUMS[$f]}" != "$new_checksum" ]; then
                echo ""
                echo -e "${CYAN}[$(date +%H:%M:%S)] Change detected: ${f}${NC}"
                bash "$SCRIPT_DIR/apply.sh" "$f"
                CHECKSUMS["$f"]="$new_checksum"
                echo -e "${GREEN}[$(date +%H:%M:%S)] Done. Waiting for changes...${NC}"
            fi
        done
        sleep 2
    done
fi
