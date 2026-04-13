#!/bin/bash
# ============================================
# Apply one or more SQL files to the running
# container WITHOUT restarting anything.
# Usage:
#   ./scripts/apply.sh stored-procedures/sp_students.sql
#   ./scripts/apply.sh migrations/*.sql
#   ./scripts/apply.sh  (no args = apply everything)
# ============================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

CONTAINER="school-db-mysql"
DB="school_db"

# Check container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
    echo -e "${RED}[ERROR] Container ${CONTAINER} is not running.${NC}"
    echo -e "${YELLOW}Run: make up${NC}"
    exit 1
fi

apply_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo -e "${RED}[ERROR] File not found: $file${NC}"
        return 1
    fi
    echo -e "${YELLOW}[*] Applying: ${file}${NC}"
    docker exec -i "${CONTAINER}" mysql -uroot -proot_secret "${DB}" < "$file" 2>/dev/null
    echo -e "${GREEN}[OK] ${file}${NC}"
}

if [ $# -eq 0 ]; then
    # No args: apply everything in order
    echo -e "${YELLOW}=== Applying migrations ===${NC}"
    for f in migrations/*.sql; do [ -f "$f" ] && apply_file "$f"; done

    echo -e "${YELLOW}=== Applying stored procedures ===${NC}"
    for f in stored-procedures/*.sql; do [ -f "$f" ] && apply_file "$f"; done

    echo ""
    echo -e "${GREEN}Done. Seeds are not re-applied automatically (use: make seed)${NC}"
else
    # With args: apply only the specified files
    for f in "$@"; do
        apply_file "$f"
    done
fi
