"""
CareFlow - Member 3, Day 5
Validate Member 2's cleaned event log as PM4Py input.

Input:
    data/hospital_event_log_cleaned.csv

Output:
    pm4py_input_validation.txt

Run:
    python validate_pm4py_input.py
"""

from pathlib import Path
import pandas as pd


BASE_DIR = Path(__file__).resolve().parent

INPUT_FILE = (
    BASE_DIR / "data" / "hospital_event_log_cleaned.csv"
)

REPORT_FILE = (
    BASE_DIR / "pm4py_input_validation.txt"
)

REQUIRED_COLUMNS = [
    "Case_ID",
    "Activity",
    "Timestamp"
]


def load_data():

    if not INPUT_FILE.exists():
        raise FileNotFoundError(
            f"File not found: {INPUT_FILE}"
        )

    df = pd.read_csv(INPUT_FILE)

    print(f"Loaded rows: {len(df)}")

    return df


def check_required_columns(df):

    missing = [
        column
        for column in REQUIRED_COLUMNS
        if column not in df.columns
    ]

    if missing:
        return False, f"Missing columns: {missing}"

    return True, "Required PM4Py columns: PASS"


def check_case_id(df):

    missing = int(
        df["Case_ID"].isna().sum()
    )

    empty = int(
        (df["Case_ID"].astype(str).str.strip() == "").sum()
    )

    if missing == 0 and empty == 0:
        return True, "Case_ID validation: PASS"

    return False, (
        f"Case_ID validation: FAIL "
        f"(missing={missing}, empty={empty})"
    )


def check_activity(df):

    missing = int(
        df["Activity"].isna().sum()
    )

    empty = int(
        (df["Activity"].astype(str).str.strip() == "").sum()
    )

    unique_activities = (
        df["Activity"].dropna().nunique()
    )

    if missing == 0 and empty == 0:
        return True, (
            f"Activity validation: PASS "
            f"({unique_activities} unique activities)"
        )

    return False, (
        f"Activity validation: FAIL "
        f"(missing={missing}, empty={empty})"
    )


def check_timestamp(df):

    timestamps = pd.to_datetime(
        df["Timestamp"],
        errors="coerce"
    )

    invalid = int(
        timestamps.isna().sum()
    )

    if invalid == 0:
        return True, "Timestamp conversion: PASS", timestamps

    return False, (
        f"Timestamp conversion: FAIL "
        f"({invalid} invalid/missing timestamps)"
    ), timestamps


def check_case_order(df, timestamps):

    temp = df.copy()

    temp["Timestamp"] = timestamps

    bad_cases = []

    for case_id, group in temp.groupby(
        "Case_ID",
        sort=False
    ):

        if not group[
            "Timestamp"
        ].is_monotonic_increasing:

            bad_cases.append(case_id)

    if not bad_cases:

        return True, (
            "Case timestamp ordering: PASS"
        )

    return False, (
        f"Case timestamp ordering: FAIL "
        f"({len(bad_cases)} cases)"
    )


def check_duplicate_events(df):

    duplicates = int(
        df.duplicated().sum()
    )

    return (
        duplicates == 0,
        f"Exact duplicate rows: {duplicates}"
    )


def test_pm4py_conversion(df, timestamps):

    try:

        from pm4py.objects.conversion.log import converter as log_converter

    except ImportError:

        return False, (
            "PM4Py is not installed. "
            "Run: pip install pm4py"
        )

    pm_df = df.copy()

    pm_df["Timestamp"] = timestamps

    try:

        event_log = log_converter.apply(
            pm_df,
            variant=log_converter.Variants.TO_EVENT_LOG,
            parameters={
                log_converter.Variants.TO_EVENT_LOG.value.Parameters.CASE_ID_KEY:
                    "Case_ID"
            }
        )

        expected_cases = (
            pm_df["Case_ID"].nunique()
        )

        actual_cases = len(event_log)

        if actual_cases != expected_cases:

            return False, (
                "PM4Py conversion: FAIL "
                f"(expected {expected_cases}, "
                f"got {actual_cases})"
            )

        return True, (
            "PM4Py conversion: PASS "
            f"({actual_cases} cases)"
        )

    except Exception as error:

        return False, (
            f"PM4Py conversion: FAIL - {error}"
        )


def main():

    df = load_data()

    report = []

    report.append(
        "CareFlow - PM4Py Input Validation"
    )

    report.append("=" * 55)

    report.append(
        f"Total records: {len(df)}"
    )

    report.append(
        f"Total cases: {df['Case_ID'].nunique()}"
    )

    # --------------------------------------------------
    # Required columns
    # --------------------------------------------------

    ok_columns, msg = (
        check_required_columns(df)
    )

    report.append(msg)

    if not ok_columns:

        raise ValueError(
            "Required PM4Py columns are missing."
        )

    # --------------------------------------------------
    # Case_ID
    # --------------------------------------------------

    ok_case, msg = check_case_id(df)

    report.append(msg)

    # --------------------------------------------------
    # Activity
    # --------------------------------------------------

    ok_activity, msg = check_activity(df)

    report.append(msg)

    # --------------------------------------------------
    # Timestamp
    # --------------------------------------------------

    ok_timestamp, msg, timestamps = (
        check_timestamp(df)
    )

    report.append(msg)

    # --------------------------------------------------
    # Timestamp ordering
    # --------------------------------------------------

    if ok_timestamp:

        ok_order, msg = (
            check_case_order(
                df,
                timestamps
            )
        )

        report.append(msg)

    else:

        ok_order = False

    # --------------------------------------------------
    # Duplicate check
    # --------------------------------------------------

    ok_duplicates, msg = (
        check_duplicate_events(df)
    )

    report.append(msg)

    # --------------------------------------------------
    # PM4Py conversion
    # --------------------------------------------------

    if (
        ok_case
        and ok_activity
        and ok_timestamp
    ):

        ok_pm4py, msg = (
            test_pm4py_conversion(
                df,
                timestamps
            )
        )

    else:

        ok_pm4py = False

        msg = (
            "PM4Py conversion: SKIPPED "
            "because required validation failed."
        )

    report.append(msg)

    # --------------------------------------------------
    # Overall result
    # --------------------------------------------------

    overall = (
        ok_columns
        and ok_case
        and ok_activity
        and ok_timestamp
        and ok_order
        and ok_pm4py
    )

    report.append("")
    report.append("=" * 55)

    if overall:

        report.append(
            "OVERALL PM4Py INPUT VALIDATION: PASS"
        )

    else:

        report.append(
            "OVERALL PM4Py INPUT VALIDATION: REVIEW REQUIRED"
        )

    REPORT_FILE.write_text(
        "\n".join(report),
        encoding="utf-8"
    )

    print("\n".join(report))

    print(
        f"\nReport saved to: {REPORT_FILE}"
    )


if __name__ == "__main__":

    main()