"""
CareFlow - Day 7
Prepare PM4Py event log from int_normalized_event_log.csv.
"""

import pandas as pd
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
INPUT_FILE = BASE_DIR / "int_normalized_event_log.csv"
OUTPUT_FILE = BASE_DIR / "pm4py_event_log.csv"

REQUIRED_COLUMNS = ["Patient_ID", "Activity", "event_timestamp"]


def main():
    if not INPUT_FILE.exists():
        raise FileNotFoundError(f"Input file not found: {INPUT_FILE}")

    df = pd.read_csv(INPUT_FILE)

    missing = [c for c in REQUIRED_COLUMNS if c not in df.columns]
    if missing:
        raise ValueError(f"Missing required columns: {missing}")

    event_log = df[REQUIRED_COLUMNS].copy()
    event_log = event_log.rename(
        columns={"Patient_ID": "Case_ID", "event_timestamp": "Timestamp"}
    )

    event_log["Case_ID"] = event_log["Case_ID"].astype(str)
    event_log["Activity"] = event_log["Activity"].astype(str)
    event_log["Timestamp"] = pd.to_datetime(
        event_log["Timestamp"], errors="coerce"
    )

    before = len(event_log)
    event_log = event_log.dropna(
        subset=["Case_ID", "Activity", "Timestamp"]
    )

    event_log = event_log.sort_values(
        ["Case_ID", "Timestamp"], kind="stable"
    ).reset_index(drop=True)

    event_log.to_csv(OUTPUT_FILE, index=False)

    print(f"Input events: {before}")
    print(f"Output events: {len(event_log)}")
    print(f"Unique cases: {event_log['Case_ID'].nunique()}")
    print(f"Unique activities: {event_log['Activity'].nunique()}")
    print(f"Saved: {OUTPUT_FILE}")


if __name__ == "__main__":
    main()
