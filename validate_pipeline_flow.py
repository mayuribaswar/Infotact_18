from pathlib import Path
import pandas as pd


# Project root
PROJECT_ROOT = Path(__file__).resolve().parents[1]

# Project directories
RAW_DATA = PROJECT_ROOT / "RAW DATA"
DBT_DIR = PROJECT_ROOT / "DBT"
PROCESS_MINING_DIR = PROJECT_ROOT / "PROCESSMINING"


def find_event_log():
    """Find the event-log CSV inside RAW DATA."""
    if not RAW_DATA.exists():
        return None

    csv_files = list(RAW_DATA.glob("*.csv"))

    if not csv_files:
        return None

    return csv_files[0]


def check_raw_data():
    print("\n[1] Checking raw event log...")

    event_log = find_event_log()

    if event_log is None:
        print("FAIL: No CSV event log found in RAW DATA.")
        return False

    print(f"PASS: Event log found: {event_log.name}")

    try:
        df = pd.read_csv(event_log)

        required_columns = [
            "Case_ID",
            "Activity",
            "Timestamp"
        ]

        missing = [
            column for column in required_columns
            if column not in df.columns
        ]

        if missing:
            print(f"FAIL: Missing columns: {missing}")
            return False

        print("PASS: Required columns are available.")
        print(f"Rows: {len(df)}")

        return True

    except Exception as e:
        print(f"FAIL: Could not read event log - {e}")
        return False


def check_dbt():
    print("\n[2] Checking dbt project...")

    if not DBT_DIR.exists():
        print("FAIL: DBT directory not found.")
        return False

    print("PASS: DBT directory found.")

    dbt_project = DBT_DIR / "dbt_project.yml"

    if dbt_project.exists():
        print("PASS: dbt_project.yml found.")
    else:
        print("WARNING: dbt_project.yml not found yet.")

    return True


def check_process_mining():
    print("\n[3] Checking PM4Py module...")

    if not PROCESS_MINING_DIR.exists():
        print("FAIL: PROCESSMINING directory not found.")
        return False

    print("PASS: PROCESSMINING directory found.")

    import_script = PROCESS_MINING_DIR / "import_dbt_output.py"

    if import_script.exists():
        print("PASS: dbt import script found.")
    else:
        print("WARNING: import_dbt_output.py not found.")

    return True


def check_pipeline_structure():
    print("\n[4] Checking pipeline structure...")

    components = {
        "RAW DATA": RAW_DATA,
        "DBT": DBT_DIR,
        "PROCESSMINING": PROCESS_MINING_DIR
    }

    all_found = True

    for name, path in components.items():
        if path.exists():
            print(f"PASS: {name}")
        else:
            print(f"FAIL: {name} not found.")
            all_found = False

    return all_found


def validate_pipeline():
    print("=" * 50)
    print("       CAREFLOW PIPELINE VALIDATION")
    print("=" * 50)

    results = []

    results.append(check_raw_data())
    results.append(check_dbt())
    results.append(check_process_mining())
    results.append(check_pipeline_structure())

    print("\n" + "=" * 50)

    if all(results):
        print("PIPELINE CHECK: PASS")
        print("All currently available pipeline components are connected.")
    else:
        print("PIPELINE CHECK: REVIEW REQUIRED")
        print("Some components are missing or incomplete.")

    print("=" * 50)


if __name__ == "__main__":
    validate_pipeline()
