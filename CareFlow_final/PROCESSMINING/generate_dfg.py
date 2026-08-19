"""
CareFlow - Member 3 - Day 8
Generate a Directly-Follows Graph (DFG) from Member 2's normalized event log.

Input:
    PROCESSMINING/int_normalized_event_log.csv

Actual columns from Member 2:
    Event_ID
    Patient_ID
    Patient_Name
    Age
    Gender
    Disease
    Severity
    Patient_Type
    Department
    Activity
    Activity_Status
    event_timestamp
    Event_Order
    Doctor_ID
    Doctor_Name
    Shift
    wait_time_minutes
    service_time_minutes
    total_process_time
    Rework_Flag
    Previous_Activity
    Next_Activity
    Delay_Reason
    Resource
    Ward
    Bed_Number
    Admission_Date
    Discharge_Date
    Outcome
    Total_Bill
    wait_category
    rework_status
    activity_priority

For PM4Py:
    Patient_ID       -> Case ID
    Activity         -> Activity
    event_timestamp  -> Timestamp

Outputs:
    PROCESSMINING/outputs/directly_follows_graph.png
    PROCESSMINING/outputs/dfg_edges.csv
"""

from pathlib import Path

import pandas as pd
import pm4py


# ============================================================
# PATHS
# ============================================================

BASE_DIR = Path(__file__).resolve().parent

INPUT_FILE = BASE_DIR / "int_normalized_event_log.csv"

OUTPUT_DIR = BASE_DIR / "outputs"

DFG_IMAGE = OUTPUT_DIR / "directly_follows_graph.png"
DFG_CSV = OUTPUT_DIR / "dfg_edges.csv"


# ============================================================
# EXPECTED COLUMNS
# ============================================================

EXPECTED_COLUMNS = [
    "Event_ID",
    "Patient_ID",
    "Patient_Name",
    "Age",
    "Gender",
    "Disease",
    "Severity",
    "Patient_Type",
    "Department",
    "Activity",
    "Activity_Status",
    "event_timestamp",
    "Event_Order",
    "Doctor_ID",
    "Doctor_Name",
    "Shift",
    "wait_time_minutes",
    "service_time_minutes",
    "total_process_time",
    "Rework_Flag",
    "Previous_Activity",
    "Next_Activity",
    "Delay_Reason",
    "Resource",
    "Ward",
    "Bed_Number",
    "Admission_Date",
    "Discharge_Date",
    "Outcome",
    "Total_Bill",
    "wait_category",
    "rework_status",
    "activity_priority",
]


# ============================================================
# MAIN FUNCTION
# ============================================================

def main():

    print("=" * 60)
    print("CareFlow - Directly-Follows Graph Generation")
    print("=" * 60)

    # --------------------------------------------------------
    # 1. Check input file
    # --------------------------------------------------------

    if not INPUT_FILE.exists():

        raise FileNotFoundError(
            f"\nInput file not found:\n"
            f"{INPUT_FILE}\n\n"
            f"Please place Member 2's "
            f"int_normalized_event_log.csv "
            f"inside the PROCESSMINING folder."
        )

    print(f"\nInput file:")
    print(INPUT_FILE)

    # --------------------------------------------------------
    # 2. Read CSV
    # --------------------------------------------------------

    df = pd.read_csv(INPUT_FILE)

    print(f"\nRows loaded    : {len(df)}")
    print(f"Columns loaded : {len(df.columns)}")

    # --------------------------------------------------------
    # 3. Display columns
    # --------------------------------------------------------

    print("\nCSV columns:")

    for column in df.columns:
        print(f"  - {column}")

    # --------------------------------------------------------
    # 4. Validate required columns
    # --------------------------------------------------------

    required_columns = [
        "Patient_ID",
        "Activity",
        "event_timestamp",
        "Event_Order",
    ]

    missing_columns = [
        column
        for column in required_columns
        if column not in df.columns
    ]

    if missing_columns:

        raise ValueError(
            "\nMissing required column(s): "
            + ", ".join(missing_columns)
            + "\n\nAvailable columns:\n"
            + ", ".join(df.columns)
        )

    print("\nRequired column validation: PASSED")

    # --------------------------------------------------------
    # 5. Select process-mining columns
    # --------------------------------------------------------

    event_df = df[
        [
            "Patient_ID",
            "Activity",
            "event_timestamp",
            "Event_Order",
        ]
    ].copy()

    # --------------------------------------------------------
    # 6. Rename columns for PM4Py
    # --------------------------------------------------------

    event_df.rename(
        columns={
            "Patient_ID": "Case_ID",
            "event_timestamp": "Timestamp",
        },
        inplace=True,
    )

    # --------------------------------------------------------
    # 7. Clean Case ID
    # --------------------------------------------------------

    event_df["Case_ID"] = (
        event_df["Case_ID"]
        .astype(str)
        .str.strip()
    )

    # --------------------------------------------------------
    # 8. Clean Activity
    # --------------------------------------------------------

    event_df["Activity"] = (
        event_df["Activity"]
        .astype(str)
        .str.strip()
    )

    # --------------------------------------------------------
    # 9. Convert timestamp
    # --------------------------------------------------------

    event_df["Timestamp"] = pd.to_datetime(
        event_df["Timestamp"],
        errors="coerce",
    )

    # --------------------------------------------------------
    # 10. Convert Event_Order
    # --------------------------------------------------------

    event_df["Event_Order"] = pd.to_numeric(
        event_df["Event_Order"],
        errors="coerce",
    )

    # --------------------------------------------------------
    # 11. Remove invalid records
    # --------------------------------------------------------

    initial_count = len(event_df)

    event_df.dropna(
        subset=[
            "Case_ID",
            "Activity",
            "Timestamp",
        ],
        inplace=True,
    )

    event_df = event_df[
        (event_df["Case_ID"] != "")
        & (event_df["Activity"] != "")
    ]

    removed_count = (
        initial_count - len(event_df)
    )

    print(f"\nInitial events : {initial_count}")
    print(f"Removed events : {removed_count}")
    print(f"Valid events   : {len(event_df)}")

    # --------------------------------------------------------
    # 12. Check empty event log
    # --------------------------------------------------------

    if event_df.empty:

        raise ValueError(
            "No valid events remain after cleaning."
        )

    # --------------------------------------------------------
    # 13. Sort events
    # --------------------------------------------------------
    #
    # Patient_ID = process case
    # Timestamp = chronological order
    # Event_Order = secondary ordering
    #
    # --------------------------------------------------------

    event_df.sort_values(
        by=[
            "Case_ID",
            "Timestamp",
            "Event_Order",
        ],
        kind="stable",
        inplace=True,
    )

    event_df.reset_index(
        drop=True,
        inplace=True,
    )

    # --------------------------------------------------------
    # 14. Remove exact duplicate events
    # --------------------------------------------------------

    duplicate_count = event_df.duplicated(
        subset=[
            "Case_ID",
            "Activity",
            "Timestamp",
        ]
    ).sum()

    print(f"Duplicate events: {duplicate_count}")

    if duplicate_count > 0:

        event_df.drop_duplicates(
            subset=[
                "Case_ID",
                "Activity",
                "Timestamp",
            ],
            keep="first",
            inplace=True,
        )

        event_df.reset_index(
            drop=True,
            inplace=True,
        )

    # --------------------------------------------------------
    # 15. Basic statistics
    # --------------------------------------------------------

    case_count = event_df[
        "Case_ID"
    ].nunique()

    activity_count = event_df[
        "Activity"
    ].nunique()

    print("\nEvent Log Statistics")
    print("-" * 60)

    print(f"Total cases      : {case_count}")
    print(f"Total activities : {activity_count}")
    print(f"Total events     : {len(event_df)}")

    print("\nActivities found:")

    for activity in sorted(
        event_df["Activity"].unique()
    ):

        print(f"  - {activity}")

    # --------------------------------------------------------
    # 16. Create PM4Py event dataframe
    # --------------------------------------------------------

    print("\nPreparing PM4Py event log...")

    pm4py_event_log = pm4py.format_dataframe(
        event_df,
        case_id="Case_ID",
        activity_key="Activity",
        timestamp_key="Timestamp",
    )

    # --------------------------------------------------------
    # 17. Generate Directly-Follows Graph
    # --------------------------------------------------------

    print(
        "\nGenerating Directly-Follows Graph..."
    )

    dfg, start_activities, end_activities = (
        pm4py.discover_dfg(
            pm4py_event_log
        )
    )

    # --------------------------------------------------------
    # 18. Create output directory
    # --------------------------------------------------------

    OUTPUT_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    # --------------------------------------------------------
    # 19. Convert DFG to CSV
    # --------------------------------------------------------

    edges = []

    for (
        source,
        target,
    ), frequency in dfg.items():

        edges.append(
            {
                "Source_Activity": source,
                "Target_Activity": target,
                "Frequency": int(frequency),
            }
        )

    dfg_edges = pd.DataFrame(
        edges,
        columns=[
            "Source_Activity",
            "Target_Activity",
            "Frequency",
        ],
    )

    # --------------------------------------------------------
    # 20. Sort DFG transitions
    # --------------------------------------------------------

    if not dfg_edges.empty:

        dfg_edges.sort_values(
            by="Frequency",
            ascending=False,
            inplace=True,
        )

        dfg_edges.reset_index(
            drop=True,
            inplace=True,
        )

    # --------------------------------------------------------
    # 21. Save DFG CSV
    # --------------------------------------------------------

    dfg_edges.to_csv(
        DFG_CSV,
        index=False,
    )

    print(
        f"\nDFG CSV saved to:\n{DFG_CSV}"
    )

    # --------------------------------------------------------
    # 22. Generate DFG image
    # --------------------------------------------------------

    print(
        "\nGenerating DFG visualization..."
    )

    pm4py.save_vis_dfg(
        dfg,
        start_activities,
        end_activities,
        str(DFG_IMAGE),
    )

    print(
        f"DFG image saved to:\n{DFG_IMAGE}"
    )

    # --------------------------------------------------------
    # 23. Display top transitions
    # --------------------------------------------------------

    if not dfg_edges.empty:

        print(
            "\nTop 10 Directly-Follows Relationships"
        )

        print("-" * 60)

        print(
            dfg_edges
            .head(10)
            .to_string(index=False)
        )

    # --------------------------------------------------------
    # 24. Final output
    # --------------------------------------------------------

    print("\n" + "=" * 60)
    print("DFG GENERATION COMPLETED SUCCESSFULLY")
    print("=" * 60)

    print(
        f"Cases           : {case_count}"
    )

    print(
        f"Activities      : {activity_count}"
    )

    print(
        f"Events          : {len(event_df)}"
    )

    print(
        f"DFG transitions : {len(dfg)}"
    )

    print(
        f"\nGenerated files:"
    )

    print(
        f"  1. {DFG_IMAGE}"
    )

    print(
        f"  2. {DFG_CSV}"
    )

    print("=" * 60)


# ============================================================
# PROGRAM ENTRY POINT
# ============================================================

if __name__ == "__main__":
    main()