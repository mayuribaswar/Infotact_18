"""
Day 2 - Test Sample Data with PM4Py
CareFlow Process Mining

Purpose:
- Read the sample hospital event log
- Validate required columns
- Convert timestamps
- Convert the DataFrame into a PM4Py EventLog
- Display basic process statistics
"""

import pandas as pd
import pm4py
from pm4py.objects.conversion.log import converter as log_converter


FILE = "sample_event_log.csv"


def main():
    # Load sample event log
    df = pd.read_csv(FILE)

    print("=" * 60)
    print("CareFlow - Day 2 PM4Py Sample Data Test")
    print("=" * 60)

    # Check required columns
    required_columns = {"Case_ID", "Activity", "Timestamp"}
    missing = required_columns - set(df.columns)

    if missing:
        raise ValueError(f"Missing required columns: {missing}")

    # Convert Timestamp to datetime
    df["Timestamp"] = pd.to_datetime(df["Timestamp"])

    # Display basic information
    print(f"Rows       : {len(df)}")
    print(f"Cases      : {df['Case_ID'].nunique()}")
    print(f"Activities : {df['Activity'].nunique()}")

    print(f"Date range : {df['Timestamp'].min()} -> {df['Timestamp'].max()}")

    print("\nActivities:")
    print(df["Activity"].value_counts())

    # Convert DataFrame to PM4Py EventLog
    event_log = log_converter.apply(
        df,
        variant=log_converter.Variants.TO_EVENT_LOG
    )

    print(f"\nPM4Py event log traces: {len(event_log)}")
    print("PM4Py sample-data test: SUCCESS")


if __name__ == "__main__":
    main()