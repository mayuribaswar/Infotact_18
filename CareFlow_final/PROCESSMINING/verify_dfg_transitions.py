import pandas as pd
from collections import Counter

INPUT_FILE = "pm4py_event_log.csv"

# Load PM4Py event log
df = pd.read_csv(INPUT_FILE)

# Convert timestamp
df["Timestamp"] = pd.to_datetime(df["Timestamp"], errors="coerce")

# Remove invalid records
df = df.dropna(subset=["Case_ID", "Activity", "Timestamp"])

# Sort events correctly
df = df.sort_values(["Case_ID", "Timestamp"])

# Create next activity
df["Next_Activity"] = df.groupby("Case_ID")["Activity"].shift(-1)

# Keep valid transitions
transitions = df.dropna(subset=["Next_Activity"]).copy()

# Count activity-to-activity transitions
transition_counts = (
    transitions
    .groupby(["Activity", "Next_Activity"])
    .size()
    .reset_index(name="Frequency")
    .sort_values("Frequency", ascending=False)
)

print("\nActivity-to-Activity Transitions")
print("=" * 50)

for _, row in transition_counts.iterrows():
    print(
        f"{row['Activity']} -> "
        f"{row['Next_Activity']} : "
        f"{row['Frequency']}"
    )

# Save result
transition_counts.to_csv(
    "dfg_activity_transitions.csv",
    index=False
)

print("\nTransition verification completed.")
print("Output: dfg_activity_transitions.csv")