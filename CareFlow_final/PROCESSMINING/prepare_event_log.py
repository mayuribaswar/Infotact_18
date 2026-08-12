"""
CareFlow - Member 3, Day 3
Prepare Member 2's raw hospital event log for PM4Py.

Default input:
    data/hospital_event_log_raw.csv

Usage:
    python prepare_event_log.py
    python prepare_event_log.py --input path/to/hospital_event_log_raw.csv

Output:
    data/prepared_event_log.csv
"""

import argparse
from pathlib import Path
import pandas as pd

BASE_DIR = Path(__file__).resolve().parent
DEFAULT_INPUT = BASE_DIR / "data" / "hospital_event_log_raw.csv"
DEFAULT_OUTPUT = BASE_DIR / "data" / "prepared_event_log.csv"

REQUIRED_COLUMNS = ["Case_ID", "Activity", "Timestamp"]


def prepare_event_log(input_file: Path, output_file: Path) -> None:
    print(f"Reading raw event log: {input_file}")

    df = pd.read_csv(input_file)
    df.columns = [str(c).strip() for c in df.columns]

    print(f"Raw rows: {len(df)}")
    print(f"Raw columns: {list(df.columns)}")

    missing = [c for c in REQUIRED_COLUMNS if c not in df.columns]
    if missing:
        raise ValueError(f"Missing PM4Py columns: {missing}")

    # Clean only fields required for process mining.
    df["Case_ID"] = df["Case_ID"].astype("string").str.strip()
    df["Activity"] = df["Activity"].astype("string").str.strip()
    df["Timestamp"] = pd.to_datetime(df["Timestamp"], errors="coerce")

    # The raw file contains activity-name variants
    # (e.g. Registration, registration, REGISTRATION).
    # Treat them as the same process activity.
    df["Activity"] = df["Activity"].str.title()

    invalid = df[REQUIRED_COLUMNS].isna().any(axis=1)
    print(f"Rows with missing/invalid required fields: {int(invalid.sum())}")
    df = df.loc[~invalid].copy()

    duplicate_count = int(df.duplicated().sum())
    print(f"Exact duplicate rows removed: {duplicate_count}")
    df = df.drop_duplicates().copy()

    # IMPORTANT:
    # Sorting does not remove loop-backs. If a patient goes
    # X-Ray -> Triage -> X-Ray, both events remain in the log.
    df = df.sort_values(
        ["Case_ID", "Timestamp"],
        kind="mergesort"
    ).reset_index(drop=True)

    # Validate ordering.
    for case_id, group in df.groupby("Case_ID", sort=False):
        if not group["Timestamp"].is_monotonic_increasing:
            raise AssertionError(
                f"Timestamp ordering failed for {case_id}"
            )

    output_file.parent.mkdir(parents=True, exist_ok=True)

    saved = df.copy()
    saved["Timestamp"] = saved["Timestamp"].dt.strftime(
        "%Y-%m-%d %H:%M:%S"
    )
    saved.to_csv(output_file, index=False)

    print("\n--- Prepared PM4Py Event Log ---")
    print(f"Rows: {len(saved)}")
    print(f"Cases: {saved['Case_ID'].nunique()}")
    print(f"Activities: {saved['Activity'].nunique()}")
    print(f"Output: {output_file}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--input",
        default=str(DEFAULT_INPUT),
        help="Path to Member 2's hospital_event_log_raw.csv"
    )
    parser.add_argument(
        "--output",
        default=str(DEFAULT_OUTPUT),
        help="Output PM4Py-ready CSV path"
    )
    args = parser.parse_args()

    prepare_event_log(Path(args.input), Path(args.output))


if __name__ == "__main__":
    main()
