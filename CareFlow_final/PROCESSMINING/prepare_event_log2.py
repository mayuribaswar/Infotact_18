import pandas as pd

# Load event log
df = pd.read_csv("../data/event_log.csv")

# Select required PM4Py columns
event_log = df[[
    "case_id",
    "activity",
    "timestamp"
]].copy()

# Convert timestamp
event_log["timestamp"] = pd.to_datetime(
    event_log["timestamp"],
    errors="coerce"
)

# Remove rows with missing required values
event_log = event_log.dropna(
    subset=["case_id", "activity", "timestamp"]
)

# Sort events chronologically for each case
event_log = event_log.sort_values(
    by=["case_id", "timestamp"]
)

# Save PM4Py-ready event log
event_log.to_csv(
    "../data/event_log_pm4py.csv",
    index=False
)

print("PM4Py event log prepared successfully!")
print(f"Total events: {len(event_log)}")
print(f"Total cases: {event_log['case_id'].nunique()}")

print("\nFirst 10 events:")
print(event_log.head(10))