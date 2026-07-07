# Simplified Version (12 Tables)

This folder is a shareable, lightweight version of the project focused on 12 core tables that support four rich use cases. It includes a preloaded SQLite database, the simplified schema, a 12-table ERD, and the use-case document for team discussion.

## Folder Layout
- Data/
  - raw/: the 12-table CSV subset and dataset metadata
  - scripts/: loader script for the simplified database
- Database/
  - mimic_demo.db: preloaded SQLite database (12 tables)
  - mimic_schema.sql: simplified schema for the 12 tables
  - mimic_erd_12.mmd and mimic_erd_12.svg: simplified ERD
- Use Cases/
  - use_cases_v2.md: four use cases using only the 12 tables
- README.md: this file

## Dataset Summary
MIMIC-IV Demo is a de-identified clinical dataset derived from real hospital care. It includes hospital-level data (admissions, labs, medications, transfers) and ICU data (ICU stays and bedside measurements). Dates are shifted for privacy, identifiers are synthetic, and free-text notes are excluded.

## Use Cases
See [Use Cases/use_cases_v2.md](Use%20Cases/use_cases_v2.md) for the 4 use cases, column descriptions, and query ideas.

## Build or Rebuild the Simplified Database
From this folder:

```bash
python Data/scripts/load_simplified_db.py --check-fks
```

This script:
- recreates `Database/mimic_demo.db`
- loads only the 12 tables from `Data/raw/`
- runs an optional foreign key check

## Open SQLite with Required Settings
From this folder:

```sql
sqlite3 Database/mimic_demo.db
PRAGMA foreign_keys = ON;
.headers on
.mode box
```

Optional integrity check:

```sql
PRAGMA foreign_key_check;
```

## Navigation Tips
- Start with the ERD in Database/mimic_erd_12.svg to see relationships.
- Use the 12-table schema in Database/mimic_schema.sql for table definitions.
- Refer to Use Cases/use_cases_v2.md to keep analyses scoped to the intended tables.
