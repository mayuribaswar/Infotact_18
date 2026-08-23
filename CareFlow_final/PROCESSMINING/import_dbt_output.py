import pandas as pd
from pathlib import Path

DBT_OUTPUT = Path(__file__).parent / "data" / "dbt_event_log.csv"

REQUIRED_COLUMNS = [
    "Case_ID",
    "Activity",
    "Timestamp"
]


def import_dbt_output():
    if not DBT_OUTPUT.exists():
        print("DBT output file not available yet.")
        print(f"Expected file: {DBT_OUTPUT}")
        return None

    df = pd.read_csv(DBT_OUTPUT)

    print("DBT output imported successfully.")
    print(f"Rows: {len(df)}")
    print(f"Columns: {len(df.columns)}")

    missing = [
        col for col in REQUIRED_COLUMNS
        if col not in df.columns
    ]

    if missing:
        print(f"Missing PM4Py columns: {missing}")
    else:
        print("PM4Py required columns are available.")

    print("\nColumns:")
    print(df.columns.tolist())

    return df


if __name__ == "__main__":
    import_dbt_output()