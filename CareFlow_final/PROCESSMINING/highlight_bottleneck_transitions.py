import pandas as pd
import matplotlib.pyplot as plt

INPUT_FILE = "fct_process_bottlenecks.csv"
OUTPUT_FILE = "highlighted_bottleneck_transitions.csv"
CHART_FILE = "bottleneck_transitions.png"

df = pd.read_csv(INPUT_FILE)

# Ignore self-transitions such as Diagnosis -> Diagnosis.
transitions = df[df["activity_from"] != df["activity_to"]].copy()

# Convert bottleneck level into a readable process-mining highlight.
transitions["highlight"] = transitions["bottleneck_level"].map({
    "High": "BOTTLENECK",
    "Medium": "WATCH",
    "Low": "NORMAL"
})

# Highest score first, then longest average transition time.
transitions = transitions.sort_values(
    ["bottleneck_score", "avg_transition_time_minutes"],
    ascending=[False, False]
)

transitions.to_csv(OUTPUT_FILE, index=False)

# Visualize the top 10 transitions.
top = transitions.head(10).sort_values(
    "avg_transition_time_minutes", ascending=True
)

plt.figure(figsize=(10, 6))
plt.barh(
    top["activity_from"] + " → " + top["activity_to"],
    top["avg_transition_time_minutes"]
)
plt.xlabel("Average Transition Time (minutes)")
plt.ylabel("Process Transition")
plt.title("Top Bottleneck Transitions")
plt.tight_layout()
plt.savefig(CHART_FILE, dpi=180, bbox_inches="tight")
plt.close()

print("Highlighted bottleneck transitions saved to:", OUTPUT_FILE)
print("Bottleneck chart saved to:", CHART_FILE)
print("\nTop bottleneck transitions:")
print(
    transitions[
        [
            "activity_from",
            "activity_to",
            "avg_transition_time_minutes",
            "bottleneck_level",
            "bottleneck_score"
        ]
    ].head(10).to_string(index=False)
)
