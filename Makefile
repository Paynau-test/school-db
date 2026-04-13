# ============================================
# school-db · Makefile
# ============================================
# Usage:
#   make up        → Start MySQL + phpMyAdmin (auto-migrates on first run)
#   make down      → Stop containers (data persists)
#   make watch     → Hot reload: edit a .sql file and it auto-applies
#   make apply     → Apply migrations + SPs to running container
#   make seed      → Run seed files
#   make reset     → Drop everything and recreate from scratch
#   make shell     → Open interactive MySQL terminal
#   make logs      → Stream MySQL logs in real time
#   make status    → Show container status
#   make nuke      → Destroy containers + data volume
# ============================================

CONTAINER = school-db-mysql
DB = school_db
COMPOSE = docker compose

.PHONY: up down watch apply seed reset shell logs status nuke db-deploy db-info help

# ── Start / Stop ────────────────────────────

up:
	@echo "Starting containers..."
	@$(COMPOSE) up -d
	@echo ""
	@echo "MySQL:      localhost:3306"
	@echo "phpMyAdmin: http://localhost:8080"
	@echo ""
	@echo "First time? Migrations and seeds run automatically."
	@echo "Already running? Use 'make apply' or 'make watch' to apply changes."

down:
	@echo "Stopping containers (data persists)..."
	@$(COMPOSE) down

# ── Hot Reload ──────────────────────────────

watch:
	@bash scripts/watch.sh

# ── Apply changes without restarting ────────

apply:
	@bash scripts/apply.sh

apply-file:
	@bash scripts/apply.sh $(FILE)

seed:
	@echo "Running seeds..."
	@for f in seeds/*.sql; do \
		echo "  -> $$f"; \
		docker exec -i $(CONTAINER) mysql -uroot -proot_secret $(DB) < "$$f" 2>/dev/null; \
	done
	@echo "Seeds complete."

# ── Full reset ──────────────────────────────

reset:
	@echo "Resetting database..."
	@docker exec -i $(CONTAINER) mysql -uroot -proot_secret -e "DROP DATABASE IF EXISTS $(DB); CREATE DATABASE $(DB) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null
	@bash scripts/apply.sh
	@$(MAKE) seed
	@echo "Reset complete."

# ── Utilities ───────────────────────────────

shell:
	@docker exec -it $(CONTAINER) mysql -uroot -proot_secret $(DB)

logs:
	@$(COMPOSE) logs -f mysql

status:
	@$(COMPOSE) ps

# ── Production (RDS) ───────────────────────

db-info:
	@echo "Reading RDS credentials from AWS..."
	@DB_HOST=$$(aws cloudformation describe-stacks --stack-name SchoolDatabase --region us-east-1 \
		--query 'Stacks[0].Outputs[?OutputKey==`DbEndpoint`].OutputValue' --output text) && \
	DB_SECRET=$$(aws secretsmanager get-secret-value --secret-id school-db-credentials --region us-east-1 \
		--query SecretString --output text) && \
	DB_USER=$$(echo "$$DB_SECRET" | python3 -c "import sys,json; print(json.load(sys.stdin)['username'])") && \
	DB_PASS=$$(echo "$$DB_SECRET" | python3 -c "import sys,json; print(json.load(sys.stdin)['password'])") && \
	echo "" && \
	echo "Host:     $$DB_HOST" && \
	echo "Database: school_db" && \
	echo "User:     $$DB_USER" && \
	echo "Password: $$DB_PASS" && \
	echo ""

db-deploy:
	@echo "Deploying to production RDS (via Lambda)..."
	@aws lambda invoke --function-name school-db-migrate \
		--region us-east-1 \
		--cli-read-timeout 120 \
		/tmp/db-migrate-response.json > /dev/null 2>&1 && \
	RESULT=$$(cat /tmp/db-migrate-response.json) && \
	STATUS=$$(echo "$$RESULT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('statusCode', 500))") && \
	if [ "$$STATUS" = "200" ]; then \
		echo "Production database updated successfully."; \
	else \
		echo "Migration failed:"; \
		echo "$$RESULT" | python3 -m json.tool; \
		exit 1; \
	fi

# ── Full destroy ────────────────────────────

nuke:
	@echo "WARNING: This destroys containers AND the data volume."
	@read -p "Type NUKE to confirm: " confirm; \
	if [ "$$confirm" = "NUKE" ]; then \
		$(COMPOSE) down -v; \
		echo "Everything destroyed. Run 'make up' to start fresh."; \
	else \
		echo "Cancelled."; \
	fi

# ── Help ────────────────────────────────────

help:
	@echo ""
	@echo "school-db commands:"
	@echo ""
	@echo "  Local (Docker):"
	@echo "    make up              Start MySQL + phpMyAdmin"
	@echo "    make down            Stop containers (data persists)"
	@echo "    make watch           Hot reload for .sql files"
	@echo "    make apply           Apply migrations + SPs"
	@echo "    make seed            Run seed files"
	@echo "    make reset           Drop DB and recreate everything"
	@echo "    make shell           Interactive MySQL terminal"
	@echo "    make logs            Stream logs in real time"
	@echo "    make status          Show container status"
	@echo "    make nuke            Destroy everything (containers + data)"
	@echo ""
	@echo "  Production (RDS):"
	@echo "    make db-info         Show RDS credentials"
	@echo "    make db-deploy       Deploy migrations + SPs to production RDS"
	@echo ""
