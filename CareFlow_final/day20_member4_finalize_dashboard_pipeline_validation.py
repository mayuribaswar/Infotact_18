"""
CareFlow - Day 20 Final Process Mining Outputs

Source:
    hospital_event_log_cleaned.csv

No BigQuery.
No dummy data.
No additional CSV files.

Purpose:
    1. Load the final cleaned hospital event log.
    2. Validate the dataset.
    3. Create actual case journeys.
    4. Define the ideal / mandated patient journey.
    5. Perform conformance analysis.
    6. Calculate conformance KPIs.
    7. Analyze process deviations.
    8. Analyze activity and department performance.
    9. Perform final validation.
"""

import pandas as pd


# =========================================================
# 1. FILE CONFIGURATION
# =========================================================

CSV_FILE = (
    r"C:\Users\aswar\OneDrive\Desktop\Infotact"
    r"\Infotact_18\CareFlow_final\PROCESSMINING"
    r"\data\hospital_event_log_cleaned.csv"
)


# =========================================================
# 2. IDEAL / MANDATED PATIENT JOURNEY
# =========================================================

IDEAL_PROCESS = [
    "Registration",
    "Triage",
    "Doctor",
    "Lab",
    "Pharmacy",
    "Discharge"
]


# =========================================================
# 3. REQUIRED COLUMNS
# =========================================================

REQUIRED_COLUMNS = [
    "Event_ID",
    "Case_ID",
    "Patient_ID",
    "Visit_Type",
    "Activity",
    "Department",
    "Timestamp",
    "Doctor_ID",
    "Severity",
    "Waiting_Time_Minutes",
    "Cost",
    "Status"
]


# =========================================================
# 4. LOAD FINAL CLEANED EVENT LOG
# =========================================================

print("\n" + "=" * 60)
print("CAREFLOW - DAY 20")
print("MEMBER 4 - FINAL DASHBOARD & PIPELINE VALIDATION")
print("=" * 60)

print("\n[1] Loading final cleaned event log...")

df = pd.read_csv(CSV_FILE)

print(f"[PASS] File loaded successfully")
print(f"      Records loaded: {len(df):,}")


# =========================================================
# 5. COLUMN VALIDATION
# =========================================================

print("\n[2] Validating required columns...")

missing_columns = [
    column
    for column in REQUIRED_COLUMNS
    if column not in df.columns
]

if missing_columns:

    print("[FAIL] Missing columns:")

    for column in missing_columns:
        print(f"      - {column}")

    raise ValueError(
        f"Required columns are missing: {missing_columns}"
    )

print("[PASS] All required columns are present")


# =========================================================
# 6. DATA PREPARATION
# =========================================================

print("\n[3] Preparing event log...")

# Remove leading/trailing spaces from text fields
text_columns = [
    "Event_ID",
    "Case_ID",
    "Patient_ID",
    "Visit_Type",
    "Activity",
    "Department",
    "Doctor_ID",
    "Severity",
    "Status"
]

for column in text_columns:

    df[column] = (
        df[column]
        .astype(str)
        .str.strip()
    )


# Convert timestamp
df["Timestamp"] = pd.to_datetime(
    df["Timestamp"],
    errors="coerce"
)


# Convert numeric fields
df["Waiting_Time_Minutes"] = pd.to_numeric(
    df["Waiting_Time_Minutes"],
    errors="coerce"
)

df["Cost"] = pd.to_numeric(
    df["Cost"],
    errors="coerce"
)


# =========================================================
# 7. DATA QUALITY CHECK
# =========================================================

print("\n[4] Running data quality checks...")

null_case = df["Case_ID"].isna().sum()
null_patient = df["Patient_ID"].isna().sum()
null_activity = df["Activity"].isna().sum()
null_timestamp = df["Timestamp"].isna().sum()

print(
    f"      NULL Case_ID   : {null_case:,}"
)

print(
    f"      NULL Patient_ID: {null_patient:,}"
)

print(
    f"      NULL Activity  : {null_activity:,}"
)

print(
    f"      NULL Timestamp : {null_timestamp:,}"
)


# Remove rows that cannot participate in process mining
before_rows = len(df)

df = df.dropna(
    subset=[
        "Case_ID",
        "Activity",
        "Timestamp"
    ]
).copy()

removed_rows = before_rows - len(df)

print(
    f"      Invalid rows removed: "
    f"{removed_rows:,}"
)


# =========================================================
# 8. SORT EVENT LOG
# =========================================================

print("\n[5] Sorting events chronologically...")

df = df.sort_values(
    by=[
        "Case_ID",
        "Timestamp"
    ]
).reset_index(drop=True)

print("[PASS] Event log sorted")


# =========================================================
# 9. CREATE ACTUAL CASE JOURNEYS
# =========================================================

print("\n[6] Creating actual case journeys...")

case_traces = (
    df.groupby("Case_ID")["Activity"]
    .apply(list)
    .to_dict()
)

print(
    f"[PASS] Cases generated: "
    f"{len(case_traces):,}"
)


# =========================================================
# 10. CONFORMANCE CHECK FUNCTION
# =========================================================

def check_conformance(actual_trace):

    ideal = IDEAL_PROCESS

    # -----------------------------------------------------
    # Exact match
    # -----------------------------------------------------

    if actual_trace == ideal:

        return {
            "status": "COMPLIANT",
            "deviation_type": "NONE",
            "missing_activities": "",
            "unexpected_activities": "",
            "repeated_activities": ""
        }


    # -----------------------------------------------------
    # Missing activities
    # -----------------------------------------------------

    missing = [
        activity
        for activity in ideal
        if activity not in actual_trace
    ]


    # -----------------------------------------------------
    # Unexpected activities
    # -----------------------------------------------------

    unexpected = [
        activity
        for activity in actual_trace
        if activity not in ideal
    ]


    # -----------------------------------------------------
    # Repeated activities
    # -----------------------------------------------------

    repeated = []

    for activity in set(actual_trace):

        if actual_trace.count(activity) > 1:

            repeated.append(activity)


    # -----------------------------------------------------
    # Check ordering
    # -----------------------------------------------------

    common_actual = [
        activity
        for activity in actual_trace
        if activity in ideal
    ]

    expected_order = [
        activity
        for activity in ideal
        if activity in common_actual
    ]

    wrong_order = (
        common_actual != expected_order
    )


    # -----------------------------------------------------
    # Identify deviations
    # -----------------------------------------------------

    deviations = []

    if missing:

        deviations.append(
            "MISSING_ACTIVITY"
        )

    if unexpected:

        deviations.append(
            "UNEXPECTED_ACTIVITY"
        )

    if wrong_order:

        deviations.append(
            "WRONG_ORDER"
        )

    if repeated:

        deviations.append(
            "REPEATED_ACTIVITY"
        )


    if not deviations:

        deviations.append(
            "PROCESS_DEVIATION"
        )


    return {

        "status":
            "NON_COMPLIANT",

        "deviation_type":
            " | ".join(deviations),

        "missing_activities":
            ", ".join(missing),

        "unexpected_activities":
            ", ".join(unexpected),

        "repeated_activities":
            ", ".join(repeated)
    }


# =========================================================
# 11. RUN CONFORMANCE ANALYSIS
# =========================================================

print("\n[7] Running conformance analysis...")

results = []

for case_id, actual_trace in case_traces.items():

    result = check_conformance(
        actual_trace
    )

    results.append({

        "Case_ID":
            case_id,

        "Actual_Journey":
            " -> ".join(actual_trace),

        **result
    })


results_df = pd.DataFrame(results)

print(
    f"[PASS] Conformance results generated "
    f"for {len(results_df):,} cases"
)


# =========================================================
# 12. CONFORMANCE KPIs
# =========================================================

total_cases = len(results_df)

compliant_cases = (
    results_df["status"]
    .eq("COMPLIANT")
    .sum()
)

non_compliant_cases = (
    results_df["status"]
    .eq("NON_COMPLIANT")
    .sum()
)


if total_cases > 0:

    compliance_rate = (
        compliant_cases /
        total_cases
    ) * 100

    non_compliance_rate = (
        non_compliant_cases /
        total_cases
    ) * 100

else:

    compliance_rate = 0.0
    non_compliance_rate = 0.0


# =========================================================
# 13. DEVIATION SUMMARY
# =========================================================

deviation_counts = {}


for _, row in results_df.iterrows():

    if row["status"] != "NON_COMPLIANT":

        continue

    deviation_list = (
        row["deviation_type"]
        .split(" | ")
    )

    for deviation in deviation_list:

        deviation_counts[deviation] = (
            deviation_counts.get(
                deviation,
                0
            ) + 1
        )


if deviation_counts:

    deviation_summary = pd.DataFrame(
        [
            {
                "Deviation_Type":
                    deviation,

                "Case_Count":
                    count
            }

            for deviation, count
            in deviation_counts.items()
        ]
    )

    deviation_summary = (
        deviation_summary
        .sort_values(
            "Case_Count",
            ascending=False
        )
        .reset_index(drop=True)
    )

else:

    deviation_summary = pd.DataFrame(
        columns=[
            "Deviation_Type",
            "Case_Count"
        ]
    )


# =========================================================
# 14. ACTIVITY PERFORMANCE
# =========================================================

activity_summary = (
    df.groupby("Activity")
    .agg(
        Event_Count=(
            "Event_ID",
            "count"
        ),

        Unique_Cases=(
            "Case_ID",
            "nunique"
        ),

        Unique_Patients=(
            "Patient_ID",
            "nunique"
        ),

        Avg_Waiting_Time_Minutes=(
            "Waiting_Time_Minutes",
            "mean"
        ),

        Avg_Cost=(
            "Cost",
            "mean"
        )
    )
    .reset_index()
)


activity_summary[
    "Avg_Waiting_Time_Minutes"
] = (
    activity_summary[
        "Avg_Waiting_Time_Minutes"
    ]
    .round(2)
)


activity_summary[
    "Avg_Cost"
] = (
    activity_summary[
        "Avg_Cost"
    ]
    .round(2)
)


activity_summary = (
    activity_summary
    .sort_values(
        "Event_Count",
        ascending=False
    )
    .reset_index(drop=True)
)


# =========================================================
# 15. DEPARTMENT PERFORMANCE
# =========================================================

department_summary = (
    df.groupby("Department")
    .agg(
        Event_Count=(
            "Event_ID",
            "count"
        ),

        Unique_Cases=(
            "Case_ID",
            "nunique"
        ),

        Unique_Patients=(
            "Patient_ID",
            "nunique"
        ),

        Avg_Waiting_Time_Minutes=(
            "Waiting_Time_Minutes",
            "mean"
        ),

        Avg_Cost=(
            "Cost",
            "mean"
        )
    )
    .reset_index()
)


department_summary[
    "Avg_Waiting_Time_Minutes"
] = (
    department_summary[
        "Avg_Waiting_Time_Minutes"
    ]
    .round(2)
)


department_summary[
    "Avg_Cost"
] = (
    department_summary[
        "Avg_Cost"
    ]
    .round(2)
)


department_summary = (
    department_summary
    .sort_values(
        "Event_Count",
        ascending=False
    )
    .reset_index(drop=True)
)


# =========================================================
# 16. FINAL PROCESS-MINING REPORT
# =========================================================

print("\n")
print("=" * 60)
print("CAREFLOW - FINAL PROCESS MINING REPORT")
print("=" * 60)


# ---------------------------------------------------------
# Dataset KPIs
# ---------------------------------------------------------

print("\nDATASET KPIs")
print("-" * 60)

print(
    f"Total Events       : "
    f"{len(df):,}"
)

print(
    f"Total Cases        : "
    f"{df['Case_ID'].nunique():,}"
)

print(
    f"Total Patients     : "
    f"{df['Patient_ID'].nunique():,}"
)

print(
    f"Total Activities   : "
    f"{df['Activity'].nunique():,}"
)

print(
    f"Total Departments  : "
    f"{df['Department'].nunique():,}"
)


# ---------------------------------------------------------
# Ideal process
# ---------------------------------------------------------

print("\nIDEAL / MANDATED PATIENT JOURNEY")
print("-" * 60)

print(
    " -> ".join(IDEAL_PROCESS)
)


# ---------------------------------------------------------
# Conformance KPIs
# ---------------------------------------------------------

print("\nCONFORMANCE KPIs")
print("-" * 60)

print(
    f"Total Cases         : "
    f"{total_cases:,}"
)

print(
    f"Compliant Cases     : "
    f"{compliant_cases:,}"
)

print(
    f"Non-Compliant Cases : "
    f"{non_compliant_cases:,}"
)

print(
    f"Compliance Rate     : "
    f"{compliance_rate:.2f}%"
)

print(
    f"Non-Compliance Rate : "
    f"{non_compliance_rate:.2f}%"
)


# ---------------------------------------------------------
# Patient / case conformance
# ---------------------------------------------------------

print("\nCASE CONFORMANCE RESULTS")
print("-" * 60)

print(
    results_df.to_string(
        index=False
    )
)


# ---------------------------------------------------------
# Deviation summary
# ---------------------------------------------------------

print("\nDEVIATION SUMMARY")
print("-" * 60)

if deviation_summary.empty:

    print(
        "No process deviations found."
    )

else:

    print(
        deviation_summary.to_string(
            index=False
        )
    )


# ---------------------------------------------------------
# Activity summary
# ---------------------------------------------------------

print("\nACTIVITY PERFORMANCE")
print("-" * 60)

print(
    activity_summary.to_string(
        index=False
    )
)


# ---------------------------------------------------------
# Department summary
# ---------------------------------------------------------

print("\nDEPARTMENT PERFORMANCE")
print("-" * 60)

print(
    department_summary.to_string(
        index=False
    )
)


# =========================================================
# 17. FINAL VALIDATION
# =========================================================

print("\n")
print("=" * 60)
print("FINAL VALIDATION")
print("=" * 60)


validation_checks = {

    "Event log contains records":
        len(df) > 0,

    "All required columns present":
        all(
            column in df.columns
            for column in REQUIRED_COLUMNS
        ),

    "Case_ID values available":
        df["Case_ID"].notna().all(),

    "Activity values available":
        df["Activity"].notna().all(),

    "Timestamp values available":
        df["Timestamp"].notna().all(),

    "Ideal process defined":
        len(IDEAL_PROCESS) > 0,

    "Case traces generated":
        len(case_traces) > 0,

    "Conformance results generated":
        len(results_df) == total_cases,

    "Conformance status available":
        "status" in results_df.columns,

    "Deviation information available":
        "deviation_type" in results_df.columns,

    "Activity summary generated":
        len(activity_summary) > 0,

    "Department summary generated":
        len(department_summary) > 0
}


all_passed = True


for check_name, passed in validation_checks.items():

    if passed:

        print(
            f"[PASS] {check_name}"
        )

    else:

        print(
            f"[FAIL] {check_name}"
        )

        all_passed = False


# =========================================================
# 18. KPI CONSISTENCY VALIDATION
# =========================================================

print("\nKPI CONSISTENCY")
print("-" * 60)


# Check 1
if (
    compliant_cases +
    non_compliant_cases
    == total_cases
):

    print(
        "[PASS] Compliant + Non-Compliant "
        "= Total Cases"
    )

else:

    print(
        "[FAIL] Conformance case count mismatch"
    )

    all_passed = False


# Check 2
if (
    round(
        compliance_rate +
        non_compliance_rate,
        2
    )
    == 100.00
):

    print(
        "[PASS] Compliance percentages "
        "sum to 100%"
    )

else:

    print(
        "[FAIL] Compliance percentage mismatch"
    )

    all_passed = False


# Check 3
if (
    len(results_df)
    == df["Case_ID"].nunique()
):

    print(
        "[PASS] One conformance result per case"
    )

else:

    print(
        "[FAIL] Case/result count mismatch"
    )

    all_passed = False


# =========================================================
# 19. FINAL STATUS
# =========================================================

print("\n")
print("=" * 60)

if all_passed:

    print(
        "FINAL VALIDATION: PASSED"
    )

    print(
        "Member 3 Day 20 process-mining "
        "analysis is complete."
    )

else:

    print(
        "FINAL VALIDATION: FAILED"
    )

    print(
        "Please review the failed checks above."
    )

print("=" * 60)


# =========================================================
# 20. MEMBER 4 - FINAL DASHBOARD & PIPELINE VALIDATION
# =========================================================
# Purpose:
# Finalize the dashboard/pipeline validation after process mining.
# This validates source data, generated outputs, KPI consistency,
# dashboard filter readiness, and conformance-result coverage.
# =========================================================

print("\n")
print("=" * 60)
print("MEMBER 4 - FINAL DASHBOARD & PIPELINE VALIDATION")
print("=" * 60)

member4_checks = {}

# Source dataset checks
member4_checks["Source dataset available"] = len(df) > 0
member4_checks["Required columns available"] = all(
    column in df.columns for column in REQUIRED_COLUMNS
)
member4_checks["Case_ID populated"] = df["Case_ID"].notna().all()
member4_checks["Activity populated"] = df["Activity"].notna().all()
member4_checks["Timestamp populated"] = df["Timestamp"].notna().all()
member4_checks["No duplicate Event_ID"] = not df["Event_ID"].duplicated().any()

# Pipeline output checks
member4_checks["Case traces generated"] = len(case_traces) > 0
member4_checks["Conformance results cover all cases"] = (
    len(results_df) == df["Case_ID"].nunique()
)
member4_checks["Activity summary generated"] = len(activity_summary) > 0
member4_checks["Department summary generated"] = len(department_summary) > 0
member4_checks["Deviation summary available"] = (
    "Deviation_Type" in deviation_summary.columns
    if not deviation_summary.empty
    else True
)

# KPI checks
member4_checks["Compliance KPI available"] = total_cases >= 0
member4_checks["Compliance + Non-Compliance = Total"] = (
    compliant_cases + non_compliant_cases == total_cases
)
member4_checks["Compliance percentages = 100%"] = (
    round(compliance_rate + non_compliance_rate, 2) == 100.00
    if total_cases > 0
    else True
)

# Dashboard filter readiness
dashboard_filter_columns = [
    "Patient_ID",
    "Doctor_ID",
    "Visit_Type",
    "Severity",
    "Department",
]
for column in dashboard_filter_columns:
    member4_checks[f"Dashboard filter: {column}"] = column in df.columns

# Final validation report
member4_validation_rows = []
for check_name, passed in member4_checks.items():
    status = "PASS" if passed else "FAIL"
    member4_validation_rows.append({
        "check_name": check_name,
        "status": status,
    })
    print(f"[{status}] {check_name}")

member4_validation_df = pd.DataFrame(member4_validation_rows)

MEMBER4_VALIDATION_FILE = "day20_member4_dashboard_pipeline_validation.csv"
member4_validation_df.to_csv(
    MEMBER4_VALIDATION_FILE,
    index=False
)

failed_checks = int(
    member4_validation_df["status"].eq("FAIL").sum()
)

print("\n" + "-" * 60)
print("DASHBOARD FINALIZATION")
print("-" * 60)
print("Recommended Power BI KPI cards:")
print("  1. Total Cases")
print("  2. Compliant Cases")
print("  3. Non-Compliant Cases")
print("  4. Compliance Rate")
print("  5. Non-Compliance Rate")

print("\nRecommended Power BI slicers:")
print("  - Patient_ID")
print("  - Doctor_ID")
print("  - Visit_Type")
print("  - Severity")
print("  - Department")
print("  - Conformance Status")
print("  - Deviation Type")

print("\nRecommended drill-down:")
print("Department -> Doctor_ID -> Patient_ID -> Activity")

print("\n" + "=" * 60)
if failed_checks == 0:
    print("FINAL DASHBOARD AND PIPELINE VALIDATION: PASSED")
else:
    print(
        f"FINAL DASHBOARD AND PIPELINE VALIDATION: FAILED "
        f"({failed_checks} checks)"
    )
print("=" * 60)

# =========================================================
# 21. MEMBER 4 DELIVERABLES
# =========================================================
# day20_member4_dashboard_pipeline_validation.csv
# Final Power BI dashboard should use the validated:
#   - results_df
#   - deviation_summary
#   - activity_summary
#   - department_summary
# =========================================================

