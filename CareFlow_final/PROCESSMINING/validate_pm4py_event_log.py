"""
CareFlow - Day 7
Validate PM4Py event log.
"""

import pandas as pd
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
INPUT_FILE = BASE_DIR / "pm4py_event_log.csv"
REQUIRED_COLUMNS = ["Case_ID", "Activity", "Timestamp"]


def main():
    if not INPUT_FILE.exists():
        raise FileNotFoundError(
            "pm4py_event_log.csv not found. Run prepare_pm4py_event_log.py first."
        )

    df = pd.read_csv(INPUT_FILE)

    print("=" * 60)
    print("CARE FLOW - PM4Py EVENT LOG VALIDATION")
    print("=" * 60)

    missing = [c for c in REQUIRED_COLUMNS if c not in df.columns]
    if missing:
        raise ValueError(f"FAIL: Missing columns: {missing}")
    print("PASS: Required columns present.")

    nulls = df[REQUIRED_COLUMNS].isna().sum()
    if nulls.sum() == 0:
        print("PASS: No NULL values in required columns.")
    else:
        print("FAIL: NULL values found:")
        print(nulls)

    timestamps = pd.to_datetime(df["Timestamp"], errors="coerce")
    invalid_timestamps = timestamps.isna().sum()
    if invalid_timestamps == 0:
        print("PASS: All timestamps are valid.")
    else:
        print(f"FAIL: {invalid_timestamps} invalid timestamps.")

    duplicate_count = df.duplicated(
        subset=["Case_ID", "Activity", "Timestamp"]
    ).sum()
    if duplicate_count == 0:
        print("PASS: No duplicate Case/Activity/Timestamp records.")
    else:
        print(f"WARNING: {duplicate_count} duplicate records found.")

    check = df.copy()
    check["Timestamp"] = timestamps
    check = check.sort_values(["Case_ID", "Timestamp"], kind="stable")

    unordered_cases = 0
    for _, group in check.groupby("Case_ID"):
        if not group["Timestamp"].is_monotonic_increasing:
            unordered_cases += 1

    if unordered_cases == 0:
        print("PASS: Events are chronologically ordered within cases.")
    else:
        print(f"FAIL: {unordered_cases} cases are not chronologically ordered.")

    print(f"Total events: {len(df)}")
    print(f"Unique cases: {df['Case_ID'].nunique()}")
    print(f"Unique activities: {df['Activity'].nunique()}")

    required_pass = (
        not missing
        and nulls.sum() == 0
        and invalid_timestamps == 0
        and unordered_cases == 0
    )

    print("=" * 60)
    print("FINAL RESULT:", "PASS" if required_pass else "REVIEW REQUIRED")
    print("=" * 60)


if __name__ == "__main__":
    main()
