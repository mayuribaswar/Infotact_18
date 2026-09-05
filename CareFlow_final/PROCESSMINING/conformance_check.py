

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

    # Fully compliant
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