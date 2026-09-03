import pandas as pd

# --------------------------------------------------
# 1. Load transition data
# --------------------------------------------------

INPUT_FILE = "int_activity_transitions.csv"
OUTPUT_FILE = "dfg_transition_pairs.csv"

df = pd.read_csv(INPUT_FILE)

print("Columns:")
print(df.columns.tolist())


# --------------------------------------------------
# 2. Check required columns
# --------------------------------------------------

required_columns = [
    "patient_id",
    "from_activity",
    "to_activity",
    "from_timestamp",
    "to_timestamp"
]

missing = [
    col for col in required_columns
    if col not in df.columns
]

if missing:
    raise ValueError(
        f"Missing columns: {missing}"
    )


# --------------------------------------------------
# 3. Convert timestamps
# --------------------------------------------------

df["from_timestamp"] = pd.to_datetime(
    df["from_timestamp"],
    errors="coerce"
)

df["to_timestamp"] = pd.to_datetime(
    df["to_timestamp"],
    errors="coerce"
)


# --------------------------------------------------
# 4. Remove invalid rows
# --------------------------------------------------

df = df.dropna(
    subset=[
        "patient_id",
        "from_activity",
        "to_activity",
        "from_timestamp",
        "to_timestamp"
    ]
)


# --------------------------------------------------
# 5. Calculate transition time
# --------------------------------------------------

df["transition_time_minutes"] = (
    df["to_timestamp"]
    - df["from_timestamp"]
).dt.total_seconds() / 60


# --------------------------------------------------
# 6. Generate transition pairs
# --------------------------------------------------

transition_pairs = (
    df.groupby(
        [
            "from_activity",
            "to_activity"
        ]
    )
    .size()
    .reset_index(
        name="frequency"
    )
)


# --------------------------------------------------
# 7. Detect self-loops
# --------------------------------------------------

transition_pairs["is_self_loop"] = (
    transition_pairs["from_activity"]
    ==
    transition_pairs["to_activity"]
)


# --------------------------------------------------
# 8. Sort by frequency
# --------------------------------------------------

transition_pairs = transition_pairs.sort_values(
    by="frequency",
    ascending=False
).reset_index(drop=True)


# --------------------------------------------------
# 9. Save result
# --------------------------------------------------

transition_pairs.to_csv(
    OUTPUT_FILE,
    index=False
)


# --------------------------------------------------
# 10. Display result
# --------------------------------------------------

print("\n==========================================")
print("DFG TRANSITION PAIRS")
print("==========================================")

print(
    transition_pairs.to_string(index=False)
)


print("\n==========================================")
print("VERIFICATION SUMMARY")
print("==========================================")

print(
    "Total records:",
    len(df)
)

print(
    "Unique patients:",
    df["patient_id"].nunique()
)

print(
    "Unique transition pairs:",
    len(transition_pairs)
)

print(
    "Self-loop transitions:",
    transition_pairs["is_self_loop"].sum()
)


print(
    f"\nOutput saved to: {OUTPUT_FILE}"
)