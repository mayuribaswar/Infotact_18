# CareFlow Process Mining

## Day 1 — BigQuery Dataset Setup

### Project

**CareFlow Process Mining**

### BigQuery Dataset

**hospital_event_log**

### Description

The `hospital_event_log` dataset is created in Google BigQuery to store and analyze hospital event-log data for the CareFlow clinical process mining project.

The project will be used to identify:

* Patient process flows
* Activity sequences
* Waiting-time bottlenecks
* Department performance
* Process inefficiencies

### Day 1 Work Completed

* Created Google Cloud project
* Created BigQuery dataset: `hospital_event_log`
* Prepared the project structure for hospital event-log analysis

### Dataset Purpose

The dataset will later contain hospital event records with information such as:

* `Case_ID`
* `Patient_ID`
* `Activity`
* `Department`
* `Timestamp`
* `Doctor_ID`
* `Nurse_ID`
* `Severity`
* `Waiting_Time_Minutes`
* `Status`

### Project Roadmap

| Day    | Task                        |
| ------ | --------------------------- |
| Day 1  | Create BigQuery dataset     |
| Day 2  | Create raw event table      |
| Day 3  | Load CSV                    |
| Day 4  | Validate schema             |
| Day 5  | Initial cleaning            |
| Day 6  | Configure dbt               |
| Day 7  | Create staging model        |
| Day 8  | Create normalized event log |
| Day 9  | Test dbt model              |
| Day 10 | Documentation               |

### Day 1 Status

**Completed ✅**

## Day 2 — Create Raw Event Table

### Objective
Create the raw hospital event-log table in Google BigQuery.

### BigQuery Setup

- **Project:** `careflow-process-mining`
- **Dataset:** `careflow_raw`
- **Raw Table:** `hospital_event`

### Dataset Information

- **Records:** 89,103
- **Columns:** 10
- **Source:** Hospital Event Log CSV
- **Storage:** Google BigQuery

### Raw Table Schema

| Column | Data Type |
|--------|-----------|
| Case_ID | STRING |
| Patient_ID | STRING |
| Activity | STRING |
| Department | STRING |
| Timestamp | TIMESTAMP |
| Doctor_ID | STRING |
| Nurse_ID | STRING |
| Severity | STRING |
| Waiting_Time_Minutes | INT64 |
| Status | STRING |

### Work Completed

- Created the raw event table in BigQuery.
- Defined the schema for the hospital event log.
- Verified the table structure.
- Prepared the table for CSV ingestion.

### SQL

The raw table creation query is available in:

`sql/02_create_raw_table.sql`

### Day 2 GitHub Commit

`feat: create raw event table`
