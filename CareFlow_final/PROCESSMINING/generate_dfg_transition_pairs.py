import pandas as pd
import pm4py

# --------------------------------------------------
# 1. Load the hospital event log
# --------------------------------------------------

INPUT_FILE = "pm4py_event_log.csv"
OUTPUT_FILE = "dfg_transition_pairs.csv"

df = pd.read_csv(INPUT_FILE)

print("Original columns:")
print(df.columns.tolist())


# --------------------------------------------------
# 2. Rename columns for PM4Py
# --------------------------------------------------

# Your event log may already contain these standard names.
# If your CSV has different names, adjust them here.

column_mapping = {
    "Case_ID": "case:concept:name",
    "Activity": "concept:name",
    "Timestamp": "time:timestamp"
}

df = df.rename(columns=column_mapping)


# --------------------------------------------------
# 3. Check required columns
# --------------------------------------------------

required_columns = [
    "case:concept:name",
    "concept:name",
    "time:timestamp"
]

missing_columns = [
    col for col in required_columns
    if col not in df.columns
]

if missing_columns:
    raise ValueError(
        f"Missing required columns: {missing_columns}\n"
        f"Available columns: {df.columns.tolist()}"
    )


# --------------------------------------------------
# 4. Convert timestamp
# --------------------------------------------------

df["time:timestamp"] = pd.to_datetime(
    df["time:timestamp"],
    errors="coerce"
)

# Remove invalid records
df = df.dropna(
    subset=[
        "case:concept:name",
        "concept:name",
        "time:timestamp"
    ]
)


# --------------------------------------------------
# 5. Sort events
# --------------------------------------------------

df = df.sort_values(
    by=[
        "case:concept:name",
        "time:timestamp"
    ]
).reset_index(drop=True)


print("\nEvent log prepared successfully.")

print("Number of cases:",
      df["case:concept:name"].nunique())

print("Number of activities:",
      df["concept:name"].nunique())


# --------------------------------------------------
# 6. Convert DataFrame to PM4Py Event Log
# --------------------------------------------------

event_log = pm4py.convert_to_event_log(df)

print("\nPM4Py Event Log created successfully.")


# --------------------------------------------------
# 7. Generate Directly-Follows Graph
# --------------------------------------------------

dfg, start_activities, end_activities = pm4py.discover_dfg(
    event_log
)


# --------------------------------------------------
# 8. Convert DFG into transition-pair table
# --------------------------------------------------

transition_rows = []

for (from_activity, to_activity), frequency in dfg.items():

    transition_rows.append({
        "from_activity": from_activity,
        "to_activity": to_activity,
        "frequency": frequency,
        "is_self_loop":
            from_activity == to_activity
    })


transition_df = pd.DataFrame(transition_rows)


# --------------------------------------------------
# 9. Sort transitions by frequency
# --------------------------------------------------

if not transition_df.empty:

    transition_df = transition_df.sort_values(
        by="frequency",
        ascending=False
    ).reset_index(drop=True)


# --------------------------------------------------
# 10. Save transition pairs
# --------------------------------------------------

transition_df.to_csv(
    OUTPUT_FILE,
    index=False
)


# --------------------------------------------------
# 11. Display results
# --------------------------------------------------

print("\n==========================================")
print("DFG TRANSITION PAIRS")
print("==========================================")

print(transition_df.to_string(index=False))


print("\n==========================================")
print("START ACTIVITIES")
print("==========================================")

print(start_activities)


print("\n==========================================")
print("END ACTIVITIES")
print("==========================================")

print(end_activities)


print("\n==========================================")
print("SUMMARY")
print("==========================================")

print(
    "Total transition pairs:",
    len(transition_df)
)

print(
    "Self-loop transitions:",
    transition_df["is_self_loop"].sum()
    if not transition_df.empty else 0
)

print(
    f"\nSaved successfully to: {OUTPUT_FILE}"
)