import argparse
import csv
import sqlite3
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser(description="Load 12-table MIMIC-IV demo subset into SQLite.")
    parser.add_argument(
        "--data-root",
        type=Path,
        default=Path(__file__).resolve().parents[2] / "Data" / "raw",
        help="Path to Simplified Version/Data/raw.",
    )
    parser.add_argument(
        "--schema",
        type=Path,
        default=Path(__file__).resolve().parents[2] / "Database" / "mimic_schema.sql",
        help="Path to simplified schema SQL.",
    )
    parser.add_argument(
        "--db",
        type=Path,
        default=Path(__file__).resolve().parents[2] / "Database" / "mimic_demo.db",
        help="SQLite database output path.",
    )
    parser.add_argument("--batch", type=int, default=1000, help="Rows per batch insert.")
    parser.add_argument("--check-fks", action="store_true", help="Run PRAGMA foreign_key_check after load.")
    args = parser.parse_args()

    hosp_tables = [
        "patients",
        "admissions",
        "transfers",
        "services",
        "d_labitems",
        "labevents",
        "prescriptions",
        "emar",
        "emar_detail",
    ]
    icu_tables = [
        "d_items",
        "icustays",
        "chartevents",
    ]

    if args.db.exists():
        args.db.unlink()

    conn = sqlite3.connect(args.db)
    try:
        conn.execute("PRAGMA foreign_keys=ON")
        conn.executescript(args.schema.read_text(encoding="utf-8"))

        for table in hosp_tables:
            path = args.data_root / "hosp" / f"{table}.csv"
            load_csv(conn, path, table, args.batch)

        for table in icu_tables:
            path = args.data_root / "icu" / f"{table}.csv"
            load_csv(conn, path, table, args.batch)

        print("Foreign keys enabled:", conn.execute("PRAGMA foreign_keys").fetchone()[0])
        if args.check_fks:
            rows = conn.execute("PRAGMA foreign_key_check").fetchall()
            print("Foreign key violations:", len(rows))
            for row in rows[:10]:
                print(row)
    finally:
        conn.close()


def load_csv(conn: sqlite3.Connection, path: Path, table: str, batch: int) -> None:
    with path.open(newline="", encoding="utf-8") as f:
        reader = csv.reader(f)
        header = next(reader)
        quoted_cols = ", ".join([f'"{col}"' for col in header])
        placeholders = ", ".join(["?"] * len(header))
        insert_sql = f'INSERT INTO "{table}" ({quoted_cols}) VALUES ({placeholders})'

        batch_rows: list[list[str | None]] = []
        row_count = 0
        for row in reader:
            batch_rows.append([None if val == "" else val for val in row])
            if len(batch_rows) >= batch:
                conn.executemany(insert_sql, batch_rows)
                row_count += len(batch_rows)
                batch_rows.clear()
        if batch_rows:
            conn.executemany(insert_sql, batch_rows)
            row_count += len(batch_rows)
        conn.commit()
        print(f"Loaded {table}: {row_count} rows")


if __name__ == "__main__":
    main()
