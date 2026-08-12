import pandas as pd
import sys

REQUIRED_COLUMNS = [
    "case_id",
    "patient_id",
    "activity",
    "timestamp"
]


def validate_csv(file_path):
    try:
        df = pd.read_csv(file_path)
    except FileNotFoundError:
        print(f"ERROR: File not found: {file_path}")
        return False
    except Exception as e:
        print(f"ERROR: Could not read CSV: {e}")
        return False

    print(f"Rows found: {len(df)}")
    print(f"Columns found: {list(df.columns)}")

    missing_columns = [
        column for column in REQUIRED_COLUMNS
        if column not in df.columns
    ]

    if missing_columns:
        print(f"FAIL: Missing columns: {missing_columns}")
        return False

    print("PASS: All required columns are present.")

    if any(str(column).strip() == "" for column in df.columns):
        print("FAIL: Empty column name found.")
        return False

    empty_rows = df.isnull().all(axis=1).sum()

    if empty_rows > 0:
        print(f"WARNING: {empty_rows} completely empty rows found.")
    else:
        print("PASS: No completely empty rows.")

    print("CSV structure validation completed.")
    return True


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python validate_csv.py <csv_file>")
        sys.exit(1)

    file_path = sys.argv[1]

    if validate_csv(file_path):
        sys.exit(0)
    else:
        sys.exit(1)
