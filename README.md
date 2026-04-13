# school-db

MySQL 8 database for the school management system. Normalized schema with stored procedures.

## Quick Start

```bash
make up       # Start MySQL + phpMyAdmin (auto-migrates + seeds on first run)
make watch    # Hot reload: edit a .sql file and it auto-applies
```

## Access

| Service    | URL                    | User        | Password    |
|------------|------------------------|-------------|-------------|
| MySQL      | localhost:3306         | school_user | school_pass |
| phpMyAdmin | http://localhost:8080  | root        | root_secret |

## Commands

```
make up       Start MySQL + phpMyAdmin
make down     Stop containers (data persists)
make watch    Hot reload for .sql files
make apply    Apply migrations + SPs without restarting
make seed     Run seed files
make reset    Drop DB and recreate everything
make shell    Interactive MySQL terminal
make nuke     Destroy containers + data
```

## Data Model

```
grades (1-9) ──< grade_subject >── subjects (12)
      └──< students ──< scores (per subject + month + year)
users (admin, teacher) ── JWT auth
```

## Stored Procedures

**Auth**: `sp_create_user`, `sp_get_user_by_email`, `sp_get_user_by_id`
**Students**: `sp_create_student`, `sp_get_student`, `sp_search_students`, `sp_update_student`, `sp_delete_student`
**Scores**: `sp_get_scores`, `sp_record_score`

## Production

Database migrations run via Lambda (inside VPC with access to RDS):

```bash
cd school-api-node && make db-deploy
```
