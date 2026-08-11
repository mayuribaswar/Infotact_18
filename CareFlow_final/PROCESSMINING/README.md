Day 1 – PM4Py Setup
Installed PM4Py and required Python libraries.
Created requirements.txt for project dependencies.
Created pm4py_setup.py to validate the PM4Py environment.
Verified PM4Py and Pandas installation.
Confirmed that PM4Py can be imported successfully.
Prepared the Process Mining environment for event-log analysis.
Day 1 Files
requirements.txt
pm4py_setup.py


Day 2 – Event Log Testing
Created a sample hospital event log using CSV format.
Loaded the event log using Pandas.
Validated required columns: Case_ID, Activity, and Timestamp.
Converted the Timestamp column into datetime format.
Checked the number of rows, cases, and activities.
Analyzed the event-log date range and activity frequency.
Converted the Pandas DataFrame into a PM4Py EventLog.
Verified that the sample event log is ready for further process-mining analysis.
Day 2 Files
sample_event_log.csv
test_pm4py_sample.py