#!/bin/bash
# ============================================
# Full DB reset script
# WARNING: Drops everything and recreates
# ============================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DB_HOST="${MYSQL_HOST:-localhost}"
DB_PORT="${MYSQL_PORT:-3306}"
DB_NAME="${MYSQL_DATABASE:-school_db}"
DB_USER="${MYSQL_USER:-root}"
DB_PASS="${MYSQL_ROOT_PASSWORD:-root_secret}"

MYSQL_CMD="mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASS}"

echo -e "${RED}========================================${NC}"
echo -e "${RED} WARNING: This will drop the entire DB${NC}"
echo -e "${RED}========================================${NC}"
read -p "Type 'RESET' to confirm: " confirm

if [ "$confirm" != "RESET" ]; then
    echo "Cancelled."
    exit 0
fi

echo -e "${YELLOW}[*] Dropping database...${NC}"
$MYSQL_CMD -e "DROP DATABASE IF EXISTS ${DB_NAME}; CREATE DATABASE ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
echo -e "${GREEN}[OK] Database recreated.${NC}"

echo -e "${YELLOW}[*] Running full migration with seeds...${NC}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$SCRIPT_DIR/migrate.sh" --seed

echo -e "${GREEN}[OK] Reset complete.${NC}"
