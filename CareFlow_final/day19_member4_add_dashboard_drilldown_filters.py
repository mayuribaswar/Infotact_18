

import pandas as pd


# =========================================================
# 1. IDEAL / MANDATED PATIENT JOURNEY
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
# 2. DUMMY PATIENT EVENT DATA
# =========================================================

dummy_data = [

    # Member 4 Day 19 - dashboard drill-down source cases
    {
        "patient_id": "P001",
        "activity": "Registration",
        "timestamp": "2026-08-01 09:00:00"
    },
    {
        "patient_id": "P001",
        "activity": "Triage",
        "timestamp": "2026-08-01 09:15:00"
    },
    {
        "patient_id": "P001",
        "activity": "Doctor",
        "timestamp": "2026-08-01 09:40:00"
    },
    {
        "patient_id": "P001",
        "activity": "Lab",
        "timestamp": "2026-08-01 10:00:00"
    },
    {
        "patient_id": "P001",
        "activity": "Pharmacy",
        "timestamp": "2026-08-01 10:30:00"
    },
    {
        "patient_id": "P001",
        "activity": "Discharge",
        "timestamp": "2026-08-01 10:45:00"
    },

    # Wrong order
    {
        "patient_id": "P002",
        "activity": "Registration",
        "timestamp": "2026-08-01 09:00:00"
    },
    {
        "patient_id": "P002",
        "activity": "Triage",
        "timestamp": "2026-08-01 09:10:00"
    },
    {
        "patient_id": "P002",
        "activity": "Doctor",
        "timestamp": "2026-08-01 09:30:00"
    },
    {
        "patient_id": "P002",
        "activity": "Pharmacy",
        "timestamp": "2026-08-01 09:50:00"
    },
    {
        "patient_id": "P002",
        "activity": "Lab",
        "timestamp": "2026-08-01 10:10:00"
    },
    {
        "patient_id": "P002",
        "activity": "Discharge",
        "timestamp": "2026-08-01 10:30:00"
    },

    # Missing Pharmacy
    {
        "patient_id": "P003",
        "activity": "Registration",
        "timestamp": "2026-08-01 08:00:00"
    },
    {
        "patient_id": "P003",
        "activity": "Triage",
        "timestamp": "2026-08-01 08:15:00"
    },
    {
        "patient_id": "P003",
        "activity": "Doctor",
        "timestamp": "2026-08-01 08:40:00"
    },
    {
        "patient_id": "P003",
        "activity": "Lab",
        "timestamp": "2026-08-01 09:00:00"
    },
    {
        "patient_id": "P003",
        "activity": "Discharge",
        "timestamp": "2026-08-01 09:30:00"
    },

    # Unexpected activity
    {
        "patient_id": "P004",
        "activity": "Registration",
        "timestamp": "2026-08-01 10:00:00"
    },
    {
        "patient_id": "P004",
        "activity": "Triage",
        "timestamp": "2026-08-01 10:15:00"
    },
    {
        "patient_id": "P004",
        "activity": "Doctor",
        "timestamp": "2026-08-01 10:40:00"
    },
    {
        "patient_id": "P004",
        "activity": "X-Ray",
        "timestamp": "2026-08-01 11:00:00"
    },
    {
        "patient_id": "P004",
        "activity": "Lab",
        "timestamp": "2026-08-01 11:20:00"
    },
    {
        "patient_id": "P004",
        "activity": "Pharmacy",
        "timestamp": "2026-08-01 11:45:00"
    },
    {
        "patient_id": "P004",
        "activity": "Discharge",
        "timestamp": "2026-08-01 12:00:00"
    },

    # Repeated Doctor activity
    {
        "patient_id": "P005",
        "activity": "Registration",
        "timestamp": "2026-08-01 07:30:00"
    },
    {
        "patient_id": "P005",
        "activity": "Triage",
        "timestamp": "2026-08-01 07:45:00"
    },
    {
        "patient_id": "P005",
        "activity": "Doctor",
        "timestamp": "2026-08-01 08:00:00"
    },
    {
        "patient_id": "P005",
        "activity": "Doctor",
        "timestamp": "2026-08-01 08:20:00"
    },
    {
        "patient_id": "P005",
        "activity": "Lab",
        "timestamp": "2026-08-01 08:40:00"
    },
    {
        "patient_id": "P005",
        "activity": "Pharmacy",
        "timestamp": "2026-08-01 09:00:00"
    },
    {
        "patient_id": "P005",
        "activity": "Discharge",
        "timestamp": "2026-08-01 09:15:00"
    }
]


# =========================================================
# 3. CREATE DATAFRAME
# =========================================================

df = pd.DataFrame(dummy_data)

df["timestamp"] = pd.to_datetime(
    df["timestamp"]
)

df = df.sort_values(
    ["patient_id", "timestamp"]
).reset_index(drop=True)


# =========================================================
# 4. CREATE PATIENT TRACES
# =========================================================

patient_traces = (
    df.groupby("patient_id")["activity"]
    .apply(list)
    .to_dict()
)


# =========================================================
# 5. CONFORMANCE CHECKING FUNCTION
# =========================================================

def check_conformance(actual_trace):

    ideal = IDEAL_PROCESS

    # Exact match
    if actual_trace == ideal:

        return {
            "status": "COMPLIANT",
            "deviation_type": "NONE",
            "missing_activities": "",
            "unexpected_activities": ""
        }

    # Activities missing from actual journey
    missing = [
        activity
        for activity in ideal
        if activity not in actual_trace
    ]

    # Activities that should not occur
    unexpected = [
        activity
        for activity in actual_trace
        if activity not in ideal
    ]

    # Check ordering
    common_activities = [
        activity
        for activity in actual_trace
        if activity in ideal
    ]

    expected_order = [
        activity
        for activity in ideal
        if activity in common_activities
    ]

    wrong_order = (
        common_activities != expected_order
    )

    deviation_types = []

    if missing:
        deviation_types.append(
            "MISSING_ACTIVITY"
        )

    if unexpected:
        deviation_types.append(
            "UNEXPECTED_ACTIVITY"
        )

    if wrong_order:
        deviation_types.append(
            "WRONG_ORDER"
        )

    if not deviation_types:
        deviation_types.append(
            "PROCESS_DEVIATION"
        )

    return {
        "status": "NON_COMPLIANT",
        "deviation_type": " | ".join(
            deviation_types
        ),
        "missing_activities": ", ".join(
            missing
        ),
        "unexpected_activities": ", ".join(
            unexpected
        )
    }


# =========================================================
# 6. RUN CONFORMANCE CHECK
# =========================================================

results = []

for patient_id, trace in patient_traces.items():

    result = check_conformance(trace)

    results.append({
        "patient_id": patient_id,
        "actual_journey": " -> ".join(trace),
        **result
    })


results_df = pd.DataFrame(results)


# =========================================================
# 7. DISPLAY IDEAL PROCESS
# =========================================================

print("\n==========================================")
print("IDEAL / MANDATED PATIENT JOURNEY")
print("==========================================")

print(
    " -> ".join(IDEAL_PROCESS)
)


# =========================================================
# 8. DISPLAY PATIENT RESULTS
# =========================================================

print("\n==========================================")
print("CONFORMANCE CHECKING RESULTS")
print("==========================================")

print(
    results_df.to_string(index=False)
)



# =========================================================
# 10. MEMBER 4 - DAY 19 DASHBOARD DRILL-DOWN FILTERS
# =========================================================
# Creates a Power BI-ready case-level dataset and event-level
# drill-down dataset from the conformance results.
#
# Drill-down/filter dimensions:
#   Patient -> Doctor -> Department -> Activity
#   Visit Type -> Severity -> Conformance Status -> Deviation
# =========================================================

print("\n==========================================")
print("MEMBER 4 - DAY 19 DASHBOARD DRILL-DOWN")
print("==========================================")

# Build case-level conformance table from the existing results_df.
case_conformance = results_df.copy()

# Create one-row-per-patient dimension data from the event log.
# The first non-null value is used for descriptive dashboard filters.
dimension_candidates = [
    "patient_id",
    "doctor_id",
    "department",
    "visit_type",
    "severity",
    "activity",
]

available_dimension_columns = [
    c for c in dimension_candidates if c in df.columns
]

if "patient_id" in df.columns:
    patient_dimensions = (
        df.groupby("patient_id", as_index=False)[
            [c for c in available_dimension_columns if c != "patient_id"]
        ]
        .first()
    )

    # Attach patient-level dimension data to case conformance results.
    dashboard_case = case_conformance.merge(
        patient_dimensions,
        on="patient_id",
        how="left",
    )
else:
    dashboard_case = case_conformance.copy()

# Add numeric dashboard flags.
dashboard_case["compliance_flag"] = (
    dashboard_case["status"].eq("COMPLIANT").astype(int)
)

dashboard_case["non_compliance_flag"] = (
    dashboard_case["status"].eq("NON_COMPLIANT").astype(int)
)

# Add readable filter groups.
dashboard_case["conformance_group"] = dashboard_case["status"]

# Create event-level drill-down dataset.
event_dashboard = df.copy()

# Attach case-level conformance to every event.
event_dashboard = event_dashboard.merge(
    case_conformance[
        [
            "patient_id",
            "status",
            "deviation_type",
            "missing_activities",
            "unexpected_activities",
        ]
    ],
    on="patient_id",
    how="left",
    suffixes=("", "_conformance"),
)

event_dashboard["compliance_flag"] = (
    event_dashboard["status"].eq("COMPLIANT").astype(int)
)

event_dashboard["non_compliance_flag"] = (
    event_dashboard["status"].eq("NON_COMPLIANT").astype(int)
)

# Add event sequence number for journey drill-down.
event_dashboard = event_dashboard.sort_values(
    ["patient_id", "timestamp"]
).reset_index(drop=True)

event_dashboard["sequence_number"] = (
    event_dashboard.groupby("patient_id").cumcount() + 1
)

# Save dashboard outputs.
case_dashboard_file = "day19_member4_dashboard_case_drilldown.csv"
event_dashboard_file = "day19_member4_dashboard_event_drilldown.csv"

dashboard_case.to_csv(
    case_dashboard_file,
    index=False,
)

event_dashboard.to_csv(
    event_dashboard_file,
    index=False,
)

# Create a filter catalogue for Power BI.
filter_catalogue = pd.DataFrame(
    [
        {
            "filter_name": "Patient",
            "column_name": "patient_id",
            "level": "Case",
            "purpose": "Drill from patient to complete journey",
        },
        {
            "filter_name": "Doctor",
            "column_name": "doctor_id",
            "level": "Case/Event",
            "purpose": "Compare journeys and deviations by doctor",
        },
        {
            "filter_name": "Department",
            "column_name": "department",
            "level": "Event",
            "purpose": "Analyse process activity by department",
        },
        {
            "filter_name": "Visit Type",
            "column_name": "visit_type",
            "level": "Case/Event",
            "purpose": "Compare different visit categories",
        },
        {
            "filter_name": "Severity",
            "column_name": "severity",
            "level": "Case/Event",
            "purpose": "Analyse compliance by severity",
        },
        {
            "filter_name": "Activity",
            "column_name": "activity",
            "level": "Event",
            "purpose": "Drill into individual process steps",
        },
        {
            "filter_name": "Conformance Status",
            "column_name": "status",
            "level": "Case",
            "purpose": "Show compliant vs non-compliant cases",
        },
        {
            "filter_name": "Deviation Type",
            "column_name": "deviation_type",
            "level": "Case",
            "purpose": "Identify the reason for non-compliance",
        },
    ]
)

filter_catalogue_file = "day19_member4_powerbi_filter_catalogue.csv"
filter_catalogue.to_csv(
    filter_catalogue_file,
    index=False,
)

print("\n[PASS] Dashboard case dataset created:")
print(f"      {case_dashboard_file}")

print("[PASS] Dashboard event dataset created:")
print(f"      {event_dashboard_file}")

print("[PASS] Power BI filter catalogue created:")
print(f"      {filter_catalogue_file}")

print("\nRECOMMENDED POWER BI DRILL-DOWN")
print("Patient -> Doctor -> Department -> Activity")
print("Conformance Status -> Deviation Type -> Patient")


# =========================================================
# 9. SUMMARY
# =========================================================

total = len(results_df)

compliant = (
    results_df["status"]
    .eq("COMPLIANT")
    .sum()
)

non_compliant = (
    results_df["status"]
    .eq("NON_COMPLIANT")
    .sum()
)


print("\n==========================================")
print("CONFORMANCE SUMMARY")
print("==========================================")

print(f"Total Patients     : {total}")
print(f"Compliant          : {compliant}")
print(f"Non-Compliant      : {non_compliant}")

print(
    f"Compliance Rate    : "
    f"{(compliant / total) * 100:.2f}%"
)

print(
    f"Non-Compliance Rate: "
    f"{(non_compliant / total) * 100:.2f}%"
)

print("==========================================")