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
## Day 4 – Pre-Cleaning Data Validation

### Objective
Validate the CareFlow raw event-log dataset before performing data cleaning and transformation.

### Tasks Completed

- Validated the raw table schema and column data types.
- Checked the total number of records.
- Checked unique patients, cases, and events.
- Identified NULL and blank values.
- Checked duplicate Event IDs and duplicate event records.
- Analyzed activity and status distributions.
- Validated timestamp ranges and case durations.
- Checked events and activities within each case.
- Analyzed patient journeys and activity sequences.
- Identified repeated and loop-back activities.
- Performed an overall data-quality assessment.
- Documented all validation queries in `04_pre_cleaning_validation.sql`.

### SQL File

`04_pre_cleaning_validation.sql`

### Outcome

The raw CareFlow dataset was successfully validated and its data-quality issues were identified. The dataset is now ready for the **data-cleaning and transformation stage**.
# CareFlow Process Mining — Day 6

## BigQuery and dbt Setup

### Objective

The objective of Day 6 was to configure the CareFlow Process Mining project using Google BigQuery and dbt.

The setup establishes the foundation for transforming hospital event data into analytics-ready datasets.

---

## Technology Stack

- Google Cloud Platform
- Google BigQuery
- dbt Core
- dbt BigQuery Adapter
- SQL
- Git
- GitHub

---

## Google Cloud Project

Project Name:

`CareFlow Process Mining`

Project ID:

`careflow-process-mining`

---

## BigQuery Datasets

The project uses the following datasets:

```text
careflow_raw
careflow_staging
careflow_mart

---

# 2. `README_Day7.md`

```markdown
# CareFlow Process Mining — Day 7

## Staging and Intermediate Transformation

### Objective

The objective of Day 7 was to create the dbt staging and intermediate transformation layers and validate the transformed hospital event data.

---

## dbt Models

### Staging Model

File:

```text
models/staging/stg_hospital_event_log.sql

---

# 3. `README_Day8.md`

```markdown
# CareFlow Process Mining — Day 8

## Mart Layer and Analytics-Ready Data

### Objective

The objective of Day 8 was to create analytics-ready fact and dimension models using dbt.

The Mart layer provides structured data for process analysis and future Power BI dashboards.

---

# Mart Architecture

The project follows this transformation flow:

```text
Raw Data
   │
   ▼
Staging
   │
   ▼
Intermediate
   │
   ▼
Mart
   │
   ├── dim_patients
   │
   └── fct_hospital_events
   │
   ▼
Power BI / Analytics