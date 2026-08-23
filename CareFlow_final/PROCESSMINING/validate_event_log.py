"""
CareFlow - Day 4
Validate the PM4Py-ready event log produced on Day 3.

Input:
    data/prepared_event_log.csv

Output:
    event_log_validation.txt

Run:
    python validate_event_log.py
"""

from pathlib import Path
import pandas as pd

BASE_DIR = Path(__file__).resolve().parent
INPUT_FILE = BASE_DIR / "data" / "prepared_event_log.csv"
REPORT_FILE = BASE_DIR / "event_log_validation.txt"

REQUIRED_COLUMNS = ["Case_ID", "Activity", "Timestamp"]


def load_event_log():
    if not INPUT_FILE.exists():
        raise FileNotFoundError(
            f"Prepared event log not found: {INPUT_FILE}\n"
            "Run prepare_event_log.py first."
        )

    df = pd.read_csv(INPUT_FILE)

    missing = [c for c in REQUIRED_COLUMNS if c not in df.columns]
    if missing:
        raise ValueError(f"Missing required columns: {missing}")

    df["Timestamp"] = pd.to_datetime(df["Timestamp"], errors="coerce")
    return df


def check_timestamp_order(df):
    bad_cases = []

    for case_id, group in df.groupby("Case_ID", sort=False):
        if not group["Timestamp"].is_monotonic_increasing:
            bad_cases.append(str(case_id))

    if bad_cases:
        return (
            "Timestamp ordering: FAIL\n"
            f"Cases with incorrect ordering: {len(bad_cases)}\n"
            f"Examples: {bad_cases[:10]}"
        )

    return "Timestamp ordering: PASS"


def find_repeated_activities(df):
    """Find repeated activities without deleting them.

    Repeated activities can represent rework/loop-back behavior.
    """
    repeated = (
        df.groupby(["Case_ID", "Activity"])
        .size()
        .reset_index(name="Occurrence_Count")
    )
    repeated = repeated[repeated["Occurrence_Count"] > 1]

    lines = [
        f"Cases containing repeated activities: {repeated['Case_ID'].nunique()}",
        f"Repeated Case_ID + Activity combinations: {len(repeated)}",
    ]

    if not repeated.empty:
        lines.append("\nSample repeated activities:")
        lines.append(repeated.head(20).to_string(index=False))

    return "\n".join(lines)


def convert_to_pm4py(df):
    try:
        from pm4py.objects.conversion.log import converter as log_converter
    except ImportError:
        return False, "PM4Py is not installed. Run: pip install pm4py"

    try:
        event_log = log_converter.apply(
            df,
            variant=log_converter.Variants.TO_EVENT_LOG,
            parameters={
                log_converter.Variants.TO_EVENT_LOG.value.Parameters.CASE_ID_KEY:
                    "Case_ID"
            },
        )

        expected_cases = df["Case_ID"].nunique()

        if len(event_log) != expected_cases:
            return False, (
                f"PM4Py case count mismatch: "
                f"{len(event_log)} != {expected_cases}"
            )

        return True, f"PM4Py EventLog conversion: PASS ({len(event_log)} cases)"

    except Exception as exc:
        return False, f"PM4Py EventLog conversion: FAIL - {exc}"


def main():
    df = load_event_log()

    report = [
        "CareFlow - Member 3 Day 4 Validation Report",
        "=" * 50,
        f"Total events: {len(df)}",
        f"Total cases: {df['Case_ID'].nunique()}",
        f"Unique activities: {df['Activity'].nunique()}",
        "",
        "Required-field validation:",
        f"Missing Case_ID: {df['Case_ID'].isna().sum()}",
        f"Missing Activity: {df['Activity'].isna().sum()}",
        f"Invalid Timestamp: {df['Timestamp'].isna().sum()}",
        "",
        f"Exact duplicate rows: {int(df.duplicated().sum())}",
        "",
        "Sequence validation:",
        check_timestamp_order(df),
        "",
        "Activities:",
    ]

    for activity in sorted(df["Activity"].dropna().unique()):
        report.append(f"- {activity}")

    report.extend([
        "",
        "Repeated activity analysis:",
        find_repeated_activities(df),
        "",
        "PM4Py validation:",
    ])

    success, pm4py_message = convert_to_pm4py(df)
    report.append(pm4py_message)

    required_ok = (
        df["Case_ID"].notna().all()
        and df["Activity"].notna().all()
        and df["Timestamp"].notna().all()
    )

    ordering_ok = all(
        group["Timestamp"].is_monotonic_increasing
        for _, group in df.groupby("Case_ID", sort=False)
    )

    overall = required_ok and ordering_ok and success

    report.extend([
        "",
        "=" * 50,
        "OVERALL VALIDATION: PASS" if overall else "OVERALL VALIDATION: FAIL",
    ])

    REPORT_FILE.write_text("\n".join(report), encoding="utf-8")

    print("\n".join(report))
    print(f"\nReport saved to: {REPORT_FILE}")


if __name__ == "__main__":
    main()
