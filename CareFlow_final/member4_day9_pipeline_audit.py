"""
CareFlow - Member 4 - Day 9
Complete Pipeline Audit

Purpose:
    Verify that the major CareFlow pipeline components exist,
    contain data, and are connected correctly.

Pipeline:
    Python EHR
        ↓
    Raw CSV
        ↓
    BigQuery
        ↓
    dbt
        ↓
    Normalized Event Log
        ↓
    PM4Py
        ↓
    DFG

Git commit:
    test: complete pipeline audit
"""

from pathlib import Path
import pandas as pd


# ============================================================
# Project Paths
# ============================================================

BASE_DIR = Path(__file__).resolve().parent.parent

# Adjust these paths if your repository structure is different.
RAW_DATA_DIR = BASE_DIR / "RAW DATA"
PROCESSING_DIR = BASE_DIR / "PROCESSMINING"
DBT_DIR = BASE_DIR / "DBT"
BIGQUERY_DIR = BASE_DIR / "BIGQUERY"

NORMALIZED_LOG = PROCESSING_DIR / "int_normalized_event_log.csv"

DFG_EDGES = PROCESSING_DIR / "outputs" / "dfg_edges.csv"
DFG_GRAPH = PROCESSING_DIR / "outputs" / "directly_follows_graph.png"


# ============================================================
# Audit Counters
# ============================================================

passed = 0
failed = 0
warnings = 0


def check(name, condition, details=""):
    """Print and record audit result."""
    global passed, failed

    if condition:
        print(f"[PASS] {name}")
        if details:
            print(f"       {details}")
        passed += 1
    else:
        print(f"[FAIL] {name}")
        if details:
            print(f"       {details}")
        failed += 1


def warning(name, details=""):
    """Print a warning without marking the pipeline as failed."""
    global warnings

    print(f"[WARN] {name}")
    if details:
        print(f"       {details}")
    warnings += 1


# ============================================================
# File Search
# ============================================================

def find_csv(directory, keywords):
    """Find a CSV file whose filename contains one of the keywords."""
    if not directory.exists():
        return None

    csv_files = list(directory.rglob("*.csv"))

    for file in csv_files:
        filename = file.name.lower()

        for keyword in keywords:
            if keyword.lower() in filename:
                return file

    return None


# ============================================================
# Audit 1 - Repository Structure
# ============================================================

def audit_directories():

    print("\n1. DIRECTORY STRUCTURE")
    print("-" * 55)

    check(
        "PROCESSMINING directory",
        PROCESSING_DIR.exists(),
        str(PROCESSING_DIR)
    )

    check(
        "DBT directory",
        DBT_DIR.exists(),
        str(DBT_DIR)
    )

    check(
        "BIGQUERY directory",
        BIGQUERY_DIR.exists(),
        str(BIGQUERY_DIR)
    )


# ============================================================
# Audit 2 - Raw Event Data
# ============================================================

def audit_raw_data():

    print("\n2. RAW EVENT DATA")
    print("-" * 55)

    raw_file = find_csv(
        RAW_DATA_DIR,
        [
            "hospital_event_log",
            "ehr",
            "event_log",
            "raw"
        ]
    )

    if raw_file is None:

        warning(
            "Raw CSV not found",
            "Check the RAW DATA folder manually."
        )

        return None

    check(
        "Raw event CSV exists",
        raw_file.exists(),
        str(raw_file)
    )

    try:

        df = pd.read_csv(raw_file)

        check(
            "Raw CSV contains records",
            len(df) > 0,
            f"{len(df)} rows found"
        )

        required_columns = [
            "Case_ID",
            "Activity",
            "Timestamp"
        ]

        missing = [
            column
            for column in required_columns
            if column not in df.columns
        ]

        check(
            "Raw CSV contains required columns",
            len(missing) == 0,
            f"Missing: {missing}" if missing else
            "Case_ID, Activity and Timestamp found"
        )

        return df

    except Exception as error:

        check(
            "Raw CSV can be loaded",
            False,
            str(error)
        )

        return None


# ============================================================
# Audit 3 - Normalized Event Log
# ============================================================

def audit_normalized_log():

    print("\n3. NORMALIZED EVENT LOG")
    print("-" * 55)

    check(
        "Normalized event log exists",
        NORMALIZED_LOG.exists(),
        str(NORMALIZED_LOG)
    )

    if not NORMALIZED_LOG.exists():
        return None

    try:

        df = pd.read_csv(NORMALIZED_LOG)

        check(
            "Normalized event log contains records",
            len(df) > 0,
            f"{len(df)} rows found"
        )

        required_columns = [
            "Case_ID",
            "Activity",
            "Timestamp"
        ]

        missing = [
            column
            for column in required_columns
            if column not in df.columns
        ]

        check(
            "Normalized log contains required columns",
            len(missing) == 0,
            f"Missing: {missing}" if missing else
            "Required columns found"
        )

        if "Case_ID" in df.columns:

            check(
                "Case_ID contains no missing values",
                df["Case_ID"].notna().all()
            )

        if "Activity" in df.columns:

            check(
                "Activity contains no missing values",
                df["Activity"].notna().all()
            )

        if "Timestamp" in df.columns:

            timestamps = pd.to_datetime(
                df["Timestamp"],
                errors="coerce"
            )

            check(
                "Timestamp values are valid",
                timestamps.notna().all(),
                f"Invalid timestamps: {timestamps.isna().sum()}"
            )

        return df

    except Exception as error:

        check(
            "Normalized event log can be loaded",
            False,
            str(error)
        )

        return None


# ============================================================
# Audit 4 - DFG Output
# ============================================================

def audit_dfg():

    print("\n4. PM4Py / DFG OUTPUT")
    print("-" * 55)

    check(
        "DFG edge file exists",
        DFG_EDGES.exists(),
        str(DFG_EDGES)
    )

    check(
        "DFG graph image exists",
        DFG_GRAPH.exists(),
        str(DFG_GRAPH)
    )

    if not DFG_EDGES.exists():
        return None

    try:

        dfg = pd.read_csv(DFG_EDGES)

        check(
            "DFG contains edges",
            len(dfg) > 0,
            f"{len(dfg)} edges found"
        )

        return dfg

    except Exception as error:

        check(
            "DFG edge file can be loaded",
            False,
            str(error)
        )

        return None


# ============================================================
# Audit 5 - Event Count Consistency
# ============================================================

def audit_event_counts(raw_df, normalized_df):

    print("\n5. EVENT COUNT CONSISTENCY")
    print("-" * 55)

    if raw_df is None or normalized_df is None:

        warning(
            "Event count comparison skipped",
            "Raw or normalized data unavailable."
        )

        return

    raw_count = len(raw_df)
    normalized_count = len(normalized_df)

    print(f"Raw event count        : {raw_count}")
    print(f"Normalized event count : {normalized_count}")

    check(
        "Normalized log contains expected events",
        normalized_count <= raw_count,
        "Normalized data should not unexpectedly exceed raw data."
    )

    if raw_count != normalized_count:

        warning(
            "Event counts differ",
            "This may be expected if dbt filtering/cleaning is applied."
        )


# ============================================================
# Audit 6 - Case Consistency
# ============================================================

def audit_cases(raw_df, normalized_df):

    print("\n6. CASE CONSISTENCY")
    print("-" * 55)

    if raw_df is None or normalized_df is None:
        return

    if "Case_ID" not in raw_df.columns:
        return

    if "Case_ID" not in normalized_df.columns:
        return

    raw_cases = set(
        raw_df["Case_ID"].dropna().astype(str)
    )

    normalized_cases = set(
        normalized_df["Case_ID"].dropna().astype(str)
    )

    missing_cases = normalized_cases - raw_cases

    check(
        "Normalized cases originate from raw data",
        len(missing_cases) == 0,
        f"Unexpected cases: {len(missing_cases)}"
    )


# ============================================================
# Audit 7 - DFG Activity Consistency
# ============================================================

def audit_dfg_activities(normalized_df, dfg_df):

    print("\n7. DFG ACTIVITY CONSISTENCY")
    print("-" * 55)

    if normalized_df is None or dfg_df is None:
        return

    if "Activity" not in normalized_df.columns:
        return

    activities = set(
        normalized_df["Activity"]
        .dropna()
        .astype(str)
    )

    possible_source_columns = [
        "source",
        "Source",
        "from",
        "From"
    ]

    possible_target_columns = [
        "target",
        "Target",
        "to",
        "To"
    ]

    source_col = next(
        (
            col for col in possible_source_columns
            if col in dfg_df.columns
        ),
        None
    )

    target_col = next(
        (
            col for col in possible_target_columns
            if col in dfg_df.columns
        ),
        None
    )

    if source_col is None or target_col is None:

        warning(
            "Could not identify DFG source/target columns",
            f"Available columns: {list(dfg_df.columns)}"
        )

        return

    dfg_activities = set(
        dfg_df[source_col].dropna().astype(str)
    ).union(
        set(
            dfg_df[target_col].dropna().astype(str)
        )
    )

    unexpected = dfg_activities - activities

    check(
        "DFG activities exist in normalized event log",
        len(unexpected) == 0,
        f"Unexpected activities: {unexpected}"
    )


# ============================================================
# Audit 8 - Duplicate Records
# ============================================================

def audit_duplicates(normalized_df):

    print("\n8. DUPLICATE RECORD CHECK")
    print("-" * 55)

    if normalized_df is None:
        return

    duplicate_count = normalized_df.duplicated().sum()

    check(
        "Normalized event log has no duplicate rows",
        duplicate_count == 0,
        f"Duplicates found: {duplicate_count}"
    )


# ============================================================
# Main Audit
# ============================================================

def main():

    print("=" * 65)
    print("CAREFLOW - COMPLETE PIPELINE AUDIT")
    print("=" * 65)

    print("\nPipeline:")
    print(
        "Python EHR → CSV → BigQuery → dbt → "
        "Normalized Event Log → PM4Py → DFG"
    )

    # Run audits

    audit_directories()

    raw_df = audit_raw_data()

    normalized_df = audit_normalized_log()

    dfg_df = audit_dfg()

    audit_event_counts(
        raw_df,
        normalized_df
    )

    audit_cases(
        raw_df,
        normalized_df
    )

    audit_dfg_activities(
        normalized_df,
        dfg_df
    )

    audit_duplicates(
        normalized_df
    )

    # ========================================================
    # Final Report
    # ========================================================

    print("\n" + "=" * 65)
    print("FINAL PIPELINE AUDIT")
    print("=" * 65)

    print(f"Passed   : {passed}")
    print(f"Failed   : {failed}")
    print(f"Warnings : {warnings}")

    print("\nPipeline status:")

    if failed == 0:

        print("PASS - Pipeline audit completed successfully.")

    else:

        print("FAIL - Pipeline audit found issues.")

    print("=" * 65)


if __name__ == "__main__":
    main()
