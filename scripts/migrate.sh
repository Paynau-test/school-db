#!/bin/bash
# ============================================
# Migration and DB setup runner
# Applies migrations, SPs and seeds in order
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

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

MYSQL_CMD="mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASS} ${DB_NAME}"

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW} School DB - Migration Runner${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""

# Wait for MySQL to be ready
echo -e "${YELLOW}[*] Waiting for MySQL...${NC}"
for i in $(seq 1 30); do
    if mysqladmin ping -h"${DB_HOST}" -P"${DB_PORT}" -u"${DB_USER}" -p"${DB_PASS}" --silent 2>/dev/null; then
        echo -e "${GREEN}[OK] MySQL is ready.${NC}"
        break
    fi
    if [ "$i" -eq 30 ]; then
        echo -e "${RED}[ERROR] MySQL not responding after 30 attempts.${NC}"
        exit 1
    fi
    sleep 2
done

echo ""

# 1. Run migrations
echo -e "${YELLOW}[1/3] Running migrations...${NC}"
for f in "$PROJECT_DIR"/migrations/*.sql; do
    echo -e "  -> $(basename "$f")"
    $MYSQL_CMD < "$f"
done
echo -e "${GREEN}[OK] Migrations complete.${NC}"
echo ""

# 2. Create stored procedures
echo -e "${YELLOW}[2/3] Creating stored procedures...${NC}"
for f in "$PROJECT_DIR"/stored-procedures/*.sql; do
    echo -e "  -> $(basename "$f")"
    $MYSQL_CMD < "$f"
done
echo -e "${GREEN}[OK] Stored procedures created.${NC}"
echo ""

# 3. Run seeds (optional with --seed flag)
if [ "$1" = "--seed" ]; then
    echo -e "${YELLOW}[3/3] Running seeds...${NC}"
    for f in "$PROJECT_DIR"/seeds/*.sql; do
        echo -e "  -> $(basename "$f")"
        $MYSQL_CMD < "$f"
    done
    echo -e "${GREEN}[OK] Seeds complete.${NC}"
else
    echo -e "${YELLOW}[3/3] Seeds skipped. Use --seed to run them.${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN} Migration completed successfully${NC}"
echo -e "${GREEN}========================================${NC}"
