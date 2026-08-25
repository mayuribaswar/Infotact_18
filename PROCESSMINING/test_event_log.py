"""
CareFlow - Member 3, Day 3
Tests for the prepared PM4Py event log.

Run:
    python test_event_log.py
"""

from pathlib import Path
import pandas as pd

DATA_FILE = Path(__file__).resolve().parent / "data" / "prepared_event_log.csv"

REQUIRED_COLUMNS = ["Case_ID", "Activity", "Timestamp"]


def load_log():
    assert DATA_FILE.exists(), f"Prepared file not found: {DATA_FILE}"
    df = pd.read_csv(DATA_FILE)
    df["Timestamp"] = pd.to_datetime(df["Timestamp"], errors="coerce")
    return df


def test_not_empty():
    df = load_log()
    assert len(df) > 0
    assert df["Case_ID"].nunique() > 0
    assert df["Activity"].nunique() > 0


def test_required_columns():
    df = load_log()
    assert all(c in df.columns for c in REQUIRED_COLUMNS)


def test_no_invalid_required_values():
    df = load_log()
    assert df["Case_ID"].notna().all()
    assert df["Activity"].notna().all()
    assert df["Timestamp"].notna().all()


def test_case_timestamp_order():
    df = load_log()

    for case_id, group in df.groupby("Case_ID", sort=False):
        assert group["Timestamp"].is_monotonic_increasing, (
            f"Events are not ordered for {case_id}"
        )


def test_no_exact_duplicates():
    df = load_log()
    assert df.duplicated().sum() == 0


def test_pm4py_conversion():
    try:
        from pm4py.objects.conversion.log import converter as log_converter
    except ImportError as exc:
        raise AssertionError(
            "PM4Py is not installed. Run: pip install pm4py"
        ) from exc

    df = load_log()

    event_log = log_converter.apply(
        df,
        variant=log_converter.Variants.TO_EVENT_LOG,
        parameters={
            log_converter.Variants.TO_EVENT_LOG.value.Parameters.CASE_ID_KEY:
                "Case_ID"
        },
    )

    assert len(event_log) == df["Case_ID"].nunique()
    assert len(event_log) > 0


if __name__ == "__main__":
    tests = [
        test_not_empty,
        test_required_columns,
        test_no_invalid_required_values,
        test_case_timestamp_order,
        test_no_exact_duplicates,
        test_pm4py_conversion,
    ]

    for test in tests:
        test()
        print(f"PASS: {test.__name__}")

    print("\nAll Member 3 Day 3 tests passed.")
