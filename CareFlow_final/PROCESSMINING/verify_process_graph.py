"""
CareFlow - Member 3 - Day 9
Verify the Directly-Follows Graph (DFG).

Input:
    PROCESSMINING/int_normalized_event_log.csv
    PROCESSMINING/outputs/dfg_edges.csv

Output:
    Console verification report

Git commit:
    test: verify process graph
"""

from pathlib import Path
import pandas as pd


# ============================================================
# Paths
# ============================================================

BASE_DIR = Path(__file__).resolve().parent

EVENT_LOG_FILE = BASE_DIR / "int_normalized_event_log.csv"
DFG_EDGES_FILE = BASE_DIR / "outputs" / "dfg_edges.csv"


# ============================================================
# Helper functions
# ============================================================

def find_column(df, possible_names):
    """
    Find a column using case-insensitive matching.
    """
    normalized = {
        str(column).strip().lower(): column
        for column in df.columns
    }

    for name in possible_names:
        if name.lower() in normalized:
            return normalized[name.lower()]

    return None


def normalize_edge_columns(df):
    """
    Detect source, target and frequency columns in dfg_edges.csv.
    """

    source_col = find_column(
        df,
        [
            "source",
            "from",
            "activity_from",
            "start_activity",
            "Activity_From"
        ]
    )

    target_col = find_column(
        df,
        [
            "target",
            "to",
            "activity_to",
            "end_activity",
            "Activity_To"
        ]
    )

    frequency_col = find_column(
        df,
        [
            "frequency",
            "count",
            "weight",
            "value",
            "occurrences"
        ]
    )

    return source_col, target_col, frequency_col


# ============================================================
# Calculate expected DFG
# ============================================================

def calculate_expected_dfg(event_log):
    """
    Calculate directly-follows relationships independently
    from the event log.
    """

    case_col = find_column(
        event_log,
        ["Case_ID", "case_id", "caseid", "case"]
    )

    activity_col = find_column(
        event_log,
        ["Activity", "activity", "event", "Event"]
    )

    timestamp_col = find_column(
        event_log,
        ["Timestamp", "timestamp", "time", "datetime"]
    )

    if not case_col:
        raise ValueError("Case_ID column not found.")

    if not activity_col:
        raise ValueError("Activity column not found.")

    if not timestamp_col:
        raise ValueError("Timestamp column not found.")

    # Convert timestamp
    event_log[timestamp_col] = pd.to_datetime(
        event_log[timestamp_col],
        errors="coerce"
    )

    # Remove invalid timestamps
    event_log = event_log.dropna(
        subset=[timestamp_col]
    ).copy()

    # Sort events by case and timestamp
    event_log = event_log.sort_values(
        by=[case_col, timestamp_col]
    )

    # Create next activity for each case
    event_log["Next_Activity"] = event_log.groupby(
        case_col
    )[activity_col].shift(-1)

    # Remove last activity of every case
    transitions = event_log.dropna(
        subset=["Next_Activity"]
    ).copy()

    # Count directly-follows relationships
    dfg = (
        transitions
        .groupby(
            [activity_col, "Next_Activity"]
        )
        .size()
        .reset_index(name="frequency")
    )

    dfg = dfg.rename(
        columns={
            activity_col: "source",
            "Next_Activity": "target"
        }
    )

    return dfg


# ============================================================
# Main verification
# ============================================================

def main():

    print("=" * 55)
    print("CareFlow - DFG Verification")
    print("=" * 55)

    # --------------------------------------------------------
    # Check files
    # --------------------------------------------------------

    if not EVENT_LOG_FILE.exists():
        print(f"\nERROR: Event log not found:")
        print(EVENT_LOG_FILE)
        return

    if not DFG_EDGES_FILE.exists():
        print(f"\nERROR: DFG edges file not found:")
        print(DFG_EDGES_FILE)
        return

    # --------------------------------------------------------
    # Load files
    # --------------------------------------------------------

    try:
        event_log = pd.read_csv(EVENT_LOG_FILE)
        generated_dfg = pd.read_csv(DFG_EDGES_FILE)
    except Exception as error:
        print(f"\nERROR while loading files: {error}")
        return

    print(f"\nEvent log file : {EVENT_LOG_FILE.name}")
    print(f"DFG file       : {DFG_EDGES_FILE.name}")

    print(f"\nEvent log rows : {len(event_log)}")

    # --------------------------------------------------------
    # Validate event log
    # --------------------------------------------------------

    required_columns = ["Case_ID", "Activity", "Timestamp"]

    missing_columns = [
        column
        for column in required_columns
        if column not in event_log.columns
    ]

    if missing_columns:
        print("\nERROR: Missing required event-log columns:")
        print(", ".join(missing_columns))
        return

    unique_activities = event_log["Activity"].nunique()

    print(f"Unique activities : {unique_activities}")

    # --------------------------------------------------------
    # Calculate expected DFG
    # --------------------------------------------------------

    try:
        expected_dfg = calculate_expected_dfg(event_log)
    except Exception as error:
        print(f"\nERROR while calculating expected DFG:")
        print(error)
        return

    # --------------------------------------------------------
    # Detect generated DFG columns
    # --------------------------------------------------------

    source_col, target_col, frequency_col = normalize_edge_columns(
        generated_dfg
    )

    if not source_col or not target_col:
        print("\nERROR: Could not identify source/target columns")
        print("Available columns:")
        print(list(generated_dfg.columns))
        return

    # --------------------------------------------------------
    # Prepare generated DFG
    # --------------------------------------------------------

    generated_dfg = generated_dfg.rename(
        columns={
            source_col: "source",
            target_col: "target"
        }
    )

    # If frequency column exists, use it.
    # Otherwise assume each edge occurs once.
    if frequency_col:
        generated_dfg = generated_dfg.rename(
            columns={frequency_col: "frequency"}
        )
    else:
        generated_dfg["frequency"] = 1

    # Keep only required columns
    generated_dfg = generated_dfg[
        ["source", "target", "frequency"]
    ].copy()

    # Convert frequency to numeric
    generated_dfg["frequency"] = pd.to_numeric(
        generated_dfg["frequency"],
        errors="coerce"
    )

    # Remove invalid rows
    generated_dfg = generated_dfg.dropna(
        subset=["source", "target", "frequency"]
    )

    # Convert frequency to integer
    generated_dfg["frequency"] = (
        generated_dfg["frequency"].astype(int)
    )

    # --------------------------------------------------------
    # Remove duplicate edges
    # --------------------------------------------------------

    generated_dfg = (
        generated_dfg
        .groupby(["source", "target"], as_index=False)
        ["frequency"]
        .sum()
    )

    expected_dfg = (
        expected_dfg
        .groupby(["source", "target"], as_index=False)
        ["frequency"]
        .sum()
    )

    # --------------------------------------------------------
    # Compare edge sets
    # --------------------------------------------------------

    expected_edges = set(
        zip(
            expected_dfg["source"],
            expected_dfg["target"]
        )
    )

    generated_edges = set(
        zip(
            generated_dfg["source"],
            generated_dfg["target"]
        )
    )

    missing_edges = expected_edges - generated_edges
    extra_edges = generated_edges - expected_edges

    # --------------------------------------------------------
    # Compare frequencies
    # --------------------------------------------------------

    expected_frequency = {
        (row["source"], row["target"]): int(row["frequency"])
        for _, row in expected_dfg.iterrows()
    }

    generated_frequency = {
        (row["source"], row["target"]): int(row["frequency"])
        for _, row in generated_dfg.iterrows()
    }

    frequency_mismatches = []

    common_edges = expected_edges.intersection(
        generated_edges
    )

    for edge in common_edges:

        expected_count = expected_frequency[edge]
        generated_count = generated_frequency[edge]

        if expected_count != generated_count:
            frequency_mismatches.append(
                (
                    edge[0],
                    edge[1],
                    expected_count,
                    generated_count
                )
            )

    # --------------------------------------------------------
    # Verification summary
    # --------------------------------------------------------

    print("\n" + "-" * 55)
    print("DFG Verification Summary")
    print("-" * 55)

    print(
        f"Expected DFG edges   : {len(expected_edges)}"
    )

    print(
        f"Generated DFG edges  : {len(generated_edges)}"
    )

    print(
        f"Missing edges        : {len(missing_edges)}"
    )

    print(
        f"Extra edges          : {len(extra_edges)}"
    )

    print(
        f"Frequency mismatches : {len(frequency_mismatches)}"
    )

    # --------------------------------------------------------
    # Display missing edges
    # --------------------------------------------------------

    if missing_edges:

        print("\nMissing edges:")

        for source, target in sorted(missing_edges):
            print(f"  {source} -> {target}")

    # --------------------------------------------------------
    # Display extra edges
    # --------------------------------------------------------

    if extra_edges:

        print("\nExtra edges:")

        for source, target in sorted(extra_edges):
            print(f"  {source} -> {target}")

    # --------------------------------------------------------
    # Display frequency mismatches
    # --------------------------------------------------------

    if frequency_mismatches:

        print("\nFrequency mismatches:")

        for source, target, expected, generated in sorted(
            frequency_mismatches
        ):
            print(
                f"  {source} -> {target} | "
                f"Expected: {expected}, "
                f"Generated: {generated}"
            )

    # --------------------------------------------------------
    # Final result
    # --------------------------------------------------------

    verification_passed = (
        len(missing_edges) == 0
        and len(extra_edges) == 0
        and len(frequency_mismatches) == 0
    )

    print("\n" + "=" * 55)

    if verification_passed:
        print("DFG VERIFICATION: PASS")
        print(
            "The generated process graph matches "
            "the event log."
        )
    else:
        print("DFG VERIFICATION: FAIL")
        print(
            "The generated process graph does not "
            "fully match the event log."
        )

    print("=" * 55)


# ============================================================
# Run
# ============================================================

if __name__ == "__main__":
    main()