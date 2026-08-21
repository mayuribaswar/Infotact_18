# CareFlow – Process Discovery Documentation

## 1. Overview

The Process Mining module analyzes the hospital event log to understand the actual patient-care workflow. PM4Py is used to prepare the event log, discover the hospital process, generate a Directly-Follows Graph (DFG), and verify the discovered process.

## 2. Input Data

The process discovery pipeline uses the normalized hospital event log generated from the dbt pipeline.

**Input file:**
`PROCESSMINING/int_normalized_event_log.csv`

Important event-log fields include:

* `Case_ID` – identifies a patient case
* `Activity` – hospital activity performed
* `Timestamp` – time at which the activity occurred

The event log is sorted chronologically for each patient case before process discovery.

## 3. PM4Py Event Log Preparation

The normalized event log is converted into a PM4Py-compatible event log using:

`prepare_pm4py_event_log.py`

The prepared event log is stored as:

`pm4py_event_log.csv`

The event data is validated to ensure that case IDs, activities, and timestamps are available and correctly formatted.

## 4. Process Discovery

The process discovery step is implemented in:

`discover_hospital_process.py`

PM4Py is used to analyze the sequence of activities performed for each patient case. The discovered process represents the actual flow of patients through the hospital workflow.

The process discovery output is stored in:

`PROCESSMINING/outputs/hospital_process_map.png`

## 5. Directly-Follows Graph

A Directly-Follows Graph (DFG) is generated to show which hospital activities occur immediately after one another.

The DFG generation is implemented in:

`generate_dfg.py`

The generated outputs include:

* `PROCESSMINING/outputs/directly_follows_graph.png`
* `PROCESSMINING/outputs/dfg_edges.csv`

The DFG helps identify frequently followed activities, alternative paths, and possible workflow deviations.

## 6. Process Graph Verification

The discovered process graph is verified using:

`verify_process_graph.py`

The verification checks whether:

* The process graph was generated successfully.
* Required activities are present.
* DFG edges contain valid activity transitions.
* The generated output files exist.
* The process discovery output is consistent with the event log.

## 7. Process Discovery Workflow

The complete Process Mining workflow is:

`int_normalized_event_log.csv`

↓

`prepare_pm4py_event_log.py`

↓

`pm4py_event_log.csv`

↓

`discover_hospital_process.py`

↓

`hospital_process_map.png`

↓

`generate_dfg.py`

↓

`directly_follows_graph.png`

↓

`verify_process_graph.py`

## 8. Output Files

| File                           | Purpose                                   |
| ------------------------------ | ----------------------------------------- |
| `int_normalized_event_log.csv` | Normalized event data from dbt            |
| `prepare_pm4py_event_log.py`   | Prepares the PM4Py event log              |
| `pm4py_event_log.csv`          | PM4Py-compatible event data               |
| `discover_hospital_process.py` | Performs process discovery                |
| `generate_dfg.py`              | Generates the Directly-Follows Graph      |
| `verify_process_graph.py`      | Verifies the discovered process           |
| `hospital_process_map.png`     | Discovered hospital process visualization |
| `directly_follows_graph.png`   | DFG visualization                         |
| `dfg_edges.csv`                | DFG transition data                       |



`docs: finalize process discovery`
