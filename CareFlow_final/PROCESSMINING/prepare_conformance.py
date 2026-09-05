

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
# 2. DUMMY HOSPITAL EVENT DATA
# =========================================================

dummy_data = [

    # -----------------------------------------------------
    # Patient P001 - COMPLIANT
    # -----------------------------------------------------

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


    # -----------------------------------------------------
    # Patient P002 - WRONG ORDER
    # -----------------------------------------------------

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


    # -----------------------------------------------------
    # Patient P003 - MISSING PHARMACY
    # -----------------------------------------------------

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


    # -----------------------------------------------------
    # Patient P004 - UNEXPECTED ACTIVITY
    # -----------------------------------------------------

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


    # -----------------------------------------------------
    # Patient P005 - REPEATED ACTIVITY
    # -----------------------------------------------------

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


# =========================================================
# 4. CONVERT TIMESTAMP
# =========================================================

df["timestamp"] = pd.to_datetime(
    df["timestamp"]
)


# =========================================================
# 5. VALIDATION
# =========================================================

print("\n==========================================")
print("DAY 18 - DATA VALIDATION")
print("==========================================")

required_columns = {
    "patient_id",
    "activity",
    "timestamp"
}

missing_columns = (
    required_columns - set(df.columns)
)

if missing_columns:
    raise ValueError(
        f"Missing columns: {missing_columns}"
    )

if df["patient_id"].isnull().any():
    raise ValueError(
        "Patient ID contains NULL values."
    )

if df["activity"].isnull().any():
    raise ValueError(
        "Activity contains NULL values."
    )

if df["timestamp"].isnull().any():
    raise ValueError(
        "Timestamp contains NULL values."
    )

print("Validation successful.")


# =========================================================
# 6. SORT PATIENT EVENTS
# =========================================================

df = df.sort_values(
    ["patient_id", "timestamp"]
).reset_index(drop=True)


# =========================================================
# 7. CREATE PATIENT TRACES
# =========================================================

patient_traces = (
    df.groupby("patient_id")["activity"]
    .apply(list)
    .to_dict()
)


# =========================================================
# 8. DISPLAY IDEAL PROCESS
# =========================================================

print("\n==========================================")
print("IDEAL / MANDATED PATIENT JOURNEY")
print("==========================================")

print(
    " -> ".join(IDEAL_PROCESS)
)


# =========================================================
# 9. DISPLAY ACTUAL PATIENT TRACES
# =========================================================

print("\n==========================================")
print("ACTUAL PATIENT TRACES")
print("==========================================")

for patient_id, trace in patient_traces.items():

    print(
        f"{patient_id}: "
        f"{' -> '.join(trace)}"
    )


# =========================================================
# 10. SUMMARY
# =========================================================

print("\n==========================================")
print("DAY 18 SUMMARY")
print("==========================================")

print(
    f"Total patients : "
    f"{df['patient_id'].nunique()}"
)

print(
    f"Total events   : "
    f"{len(df)}"
)

print(
    f"Activities     : "
    f"{df['activity'].nunique()}"
)

print(
    "\nDay 18 preparation completed."
)

print(
    "Actual patient traces are ready "
    "for Day 19 conformance checking."
)

print("==========================================")