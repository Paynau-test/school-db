#!/bin/bash
# ============================================
# Docker entrypoint init script
# Runs ONLY the first time MySQL initializes
# the data volume.
# MySQL is already running when this executes.
# ============================================

echo "[school-db] Running initial migrations..."

MYSQL_CMD="mysql -uroot -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE}"

# 1. Migrations
for f in /sql/migrations/*.sql; do
    [ -f "$f" ] || continue
    echo "[school-db]   -> $(basename "$f")"
    $MYSQL_CMD < "$f"
done

# 2. Stored procedures
for f in /sql/stored-procedures/*.sql; do
    [ -f "$f" ] || continue
    echo "[school-db]   -> $(basename "$f")"
    $MYSQL_CMD < "$f"
done

# 3. Seeds
for f in /sql/seeds/*.sql; do
    [ -f "$f" ] || continue
    echo "[school-db]   -> $(basename "$f")"
    $MYSQL_CMD < "$f"
done

echo "[school-db] Initialization complete."
