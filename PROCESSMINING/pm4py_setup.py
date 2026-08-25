"""
Day 1 - PM4Py Setup
CareFlow Process Mining

Purpose:
- Verify that PM4Py is installed correctly.
- Verify that pandas is available.
- Print the installed PM4Py version.
"""

import pm4py
import pandas as pd


def check_pm4py_setup():
    print("=" * 50)
    print("CareFlow - PM4Py Setup Check")
    print("=" * 50)

    print(f"PM4Py version : {pm4py.__version__}")
    print(f"Pandas version: {pd.__version__}")
    print("PM4Py import  : SUCCESS")
    print("Setup is ready for process mining.")


if __name__ == "__main__":
    check_pm4py_setup()