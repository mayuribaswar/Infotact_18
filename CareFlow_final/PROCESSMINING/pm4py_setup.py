import os
import pandas as pd
import pm4py


DATA_PATH = os.path.join(
    os.path.dirname(__file__),
    "..",
    "data",
    "hospital_event_log.xls"
)


def main():
    print("=" * 50)
    print("CareFlow - PM4Py Environment Setup")
    print("=" * 50)

    # Check PM4Py
    print(f"\nPM4Py version: {pm4py.__version__}")
    print("PM4Py installation: SUCCESS")

    # Check dataset
    if os.path.exists(DATA_PATH):
        print("\nHospital event log: FOUND")

        try:
            df = pd.read_excel(DATA_PATH)

            print(f"Rows: {len(df)}")
            print(f"Columns: {len(df.columns)}")
            print("\nColumns:")
            print(list(df.columns))

            print("\nDataset loaded successfully.")

        except Exception as e:
            print(f"\nDataset loading failed: {e}")

    else:
        print("\nHospital event log: NOT FOUND")
        print(f"Expected path: {DATA_PATH}")


if __name__ == "__main__":
    main()