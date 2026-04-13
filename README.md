# school-db

MySQL database for the school management system. Normalized schema, stored procedures, seeds, and hot reload for local development.

## Requirements

- Docker and Docker Compose
- Make
- (Optional) `fswatch` on macOS or `inotify-tools` on Linux for native hot reload

## Quick Start

```bash
make up       # Start MySQL + phpMyAdmin (auto-migrates and seeds on first run)
make watch    # Hot reload: edit a .sql file and it auto-applies
```

That's it. On first container start, migrations, stored procedures, and seeds run automatically.

## Available Commands

```
make up          Start MySQL + phpMyAdmin
make down        Stop containers (data persists)
make watch       Hot reload for .sql files
make apply       Apply migrations + SPs without restarting
make seed        Run seed files
make reset       Drop DB and recreate everything
make shell       Interactive MySQL terminal
make logs        Stream logs in real time
make status      Show container status
make nuke        Destroy everything (containers + data)
```

## Development Workflow

```
1. make up                    → Only once (or after make down)
2. make watch                 → Keep it running in a terminal
3. Edit any .sql file         → Auto-applied instantly
4. make shell                 → Test queries manually
```

No container restarts needed. The watcher detects changes and applies them instantly.

## Access

| Service     | URL / Host             | User         | Password     |
|-------------|------------------------|--------------|--------------|
| MySQL       | localhost:3306         | school_user  | school_pass  |
| MySQL root  | localhost:3306         | root         | root_secret  |
| phpMyAdmin  | http://localhost:8080  | root         | root_secret  |

## Project Structure

```
school-db/
├── docker-compose.yml
├── Makefile                         ← Single point of control
├── migrations/
│   └── 001_create_tables.sql
├── stored-procedures/
│   ├── sp_students.sql              ← CRUD: create, get, search, update, delete
│   └── sp_scores.sql                ← Get and record scores
├── seeds/
│   ├── 001_grades.sql
│   ├── 002_subjects.sql
│   ├── 003_grade_subject.sql
│   ├── 004_students_demo.sql
│   └── 005_scores_demo.sql
└── scripts/
    ├── apply.sh                     ← Apply SQL without restarting containers
    ├── docker-init.sh               ← Auto-migrates on first boot
    ├── migrate.sh                   ← Migration runner
    ├── reset.sh                     ← Destructive reset
    └── watch.sh                     ← Hot reload
```

## Data Model

```
grades (1-9)
  │
  ├──< grade_subject >── subjects
  │
  └──< students
         │
         └──< scores (student + subject + grade + year + month)
```

## Stored Procedures

### Students
- `sp_create_student(first_name, last_name_father, last_name_mother, date_of_birth, gender, grade_id)`
- `sp_get_student(student_id)`
- `sp_search_students(term, status, limit, offset)` — Partial name search
- `sp_update_student(student_id, first_name, last_name_father, last_name_mother, date_of_birth, gender, grade_id, status)`
- `sp_delete_student(student_id)` — Soft delete (sets status to inactive)

### Scores
- `sp_get_scores(student_id, grade_id, year, month)` — Lists all grade subjects with score or NULL
- `sp_record_score(student_id, subject_id, grade_id, year, month, score)` — Upsert

## Connecting from APIs

### Node.js (Requirement 1)
```javascript
const mysql = require('mysql2/promise');
const pool = mysql.createPool({
  host: process.env.MYSQL_HOST || 'localhost',
  port: process.env.MYSQL_PORT || 3306,
  database: process.env.MYSQL_DATABASE || 'school_db',
  user: process.env.MYSQL_USER || 'school_user',
  password: process.env.MYSQL_PASSWORD || 'school_pass',
});

// Call stored procedure
const [rows] = await pool.execute('CALL sp_search_students(?, ?, ?, ?)', ['Garcia', null, 10, 0]);
```

### C# .NET Core (Requirement 2)
```csharp
var connectionString = "Server=localhost;Port=3306;Database=school_db;User=school_user;Password=school_pass;";

using var connection = new MySqlConnection(connectionString);
using var command = new MySqlCommand("sp_get_scores", connection);
command.CommandType = CommandType.StoredProcedure;
command.Parameters.AddWithValue("p_student_id", studentId);
```
