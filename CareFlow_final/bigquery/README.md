# CareFlow Process Mining

## Day 1 — BigQuery Dataset Setup

### Project

**CareFlow Process Mining**

### BigQuery Dataset

**careflow_raw**

### Description

The `careflow_raw` dataset is created in Google BigQuery to store and analyze raw hospital event-log data for the CareFlow clinical process mining project.

The project will be used to identify:

* Patient process flows
* Activity sequences
* Waiting-time bottlenecks
* Department performance
* Process inefficiencies

### Day 1 Work Completed

* Created Google Cloud project
* Created BigQuery dataset: `careflow_raw`
* Prepared the BigQuery environment for hospital event-log analysis

### Dataset Purpose

The dataset will store raw hospital event records containing information such as:

* `Event_ID`
* `Case_ID`
* `Patient_ID`
* `Visit_Type`
* `Activity`
* `Department`
* `Timestamp`
* `Doctor_ID`
* `Severity`
* `Waiting_Time_Minutes`
* `Cost`
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

---

## Day 2 — Create Raw Event Table

### Objective

Create the raw hospital event-log table in Google BigQuery.

### BigQuery Setup

* **Project:** `careflow-process-mining`
* **Dataset:** `careflow_raw`
* **Raw Table:** `hospital_event_log`

### Source Data

The raw table is designed to store the hospital event-log data provided as the project source dataset.

### Raw Table Schema

| Column                 | Data Type |
| ---------------------- | --------- |
| `Event_ID`             | STRING    |
| `Case_ID`              | STRING    |
| `Patient_ID`           | STRING    |
| `Visit_Type`           | STRING    |
| `Activity`             | STRING    |
| `Department`           | STRING    |
| `Timestamp`            | TIMESTAMP |
| `Doctor_ID`            | STRING    |
| `Severity`             | STRING    |
| `Waiting_Time_Minutes` | INT64     |
| `Cost`                 | FLOAT64   |
| `Status`               | STRING    |

### Work Completed

* Created the raw event table in BigQuery.
* Defined the table schema according to the source CSV.
* Verified the table structure.
* Prepared the table for CSV ingestion.

### SQL

The raw table creation query is available in:

`bigquery/02_create_raw_table.sql`

### Day 2 GitHub Commit

`feat: create raw event table`

### Day 2 Status

**Completed ✅**

---

## Day 3 — Load Event Log into BigQuery

### Objective

Load the raw hospital event-log CSV into the BigQuery raw table.

### Data Preparation

* Received the hospital event-log data in Excel format.
* Converted the Excel file into CSV format.
* Prepared the raw CSV file for BigQuery ingestion.

### BigQuery Setup

* **Project:** `careflow-process-mining`
* **Dataset:** `careflow_raw`
* **Raw Table:** `hospital_event_log`

### Raw Event Log Information

* **Source:** Hospital Event Log CSV
* **Format:** CSV
* **Storage:** Google BigQuery
* **Table:** `hospital_event_log`

### Loaded CSV Schema

| Column                 | Data Type |
| ---------------------- | --------- |
| `Event_ID`             | STRING    |
| `Case_ID`              | STRING    |
| `Patient_ID`           | STRING    |
| `Visit_Type`           | STRING    |
| `Activity`             | STRING    |
| `Department`           | STRING    |
| `Timestamp`            | TIMESTAMP |
| `Doctor_ID`            | STRING    |
| `Severity`             | STRING    |
| `Waiting_Time_Minutes` | INT64     |
| `Cost`                 | FLOAT64   |
| `Status`               | STRING    |

### Work Completed

* Converted the source Excel file into CSV format.
* Loaded the raw CSV file into BigQuery.
* Stored the data in the `hospital_event_log` table.
* Verified that the data was successfully loaded.
* Verified the loaded records using BigQuery SQL queries.

### Data File

The raw CSV file is stored in:

`data/hospital_event_log_raw.csv`

### SQL

The Day 3 SQL file is available in:

`bigquery/03_load_event_log.sql`

### Verification Queries

```sql
SELECT COUNT(*) AS total_records
FROM `careflow-process-mining.careflow_raw.hospital_event_log`;
```

```sql
SELECT *
FROM `careflow-process-mining.careflow_raw.hospital_event_log`
LIMIT 10;
```

### Day 3 GitHub Commit

`feat: load event log into BigQuery`

### Day 3 Status

**Completed ✅**
