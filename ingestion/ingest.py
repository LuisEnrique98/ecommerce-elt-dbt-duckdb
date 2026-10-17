from pathlib import Path
import duckdb

RAW_DIR = Path("data/raw")
DB_PATH = Path("olist.duckdb")


def main():
    csv_files = sorted(RAW_DIR.glob("*.csv"))
    if not csv_files:
        raise FileNotFoundError(f"No hay CSV en {RAW_DIR.resolve()}")

    con = duckdb.connect(str(DB_PATH))
    con.execute("CREATE SCHEMA IF NOT EXISTS raw")

    for csv in csv_files:
        table = csv.stem  # nombre del archivo sin .csv
        con.execute(
            f"""
            CREATE OR REPLACE TABLE raw.{table} AS
            SELECT * FROM read_csv_auto('{csv.as_posix()}', header=true)
            """
        )
        n = con.execute(f"SELECT COUNT(*) FROM raw.{table}").fetchone()[0]
        print(f"{table}: {n} filas")

    con.close()


if __name__ == "__main__":
    main()