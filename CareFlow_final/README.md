# CareFlow Process Mining

## Clinical Process Mining and Patient Journey Analysis

CareFlow Process Mining is a data analytics and process mining project designed to analyze hospital event data and understand patient journeys through different clinical activities.

The project uses **Google BigQuery, dbt, SQL, Python, and Power BI** to build a data pipeline, transform hospital event data, identify patient process flows, and prepare the data for process mining and dashboard analysis.

---

# 1. Project Objective

The main objective of CareFlow Process Mining is to:

* Analyze hospital patient event data.
* Understand patient activity sequences.
* Identify waiting-time and process bottlenecks.
* Analyze transitions between clinical activities.
* Calculate process and transition times.
* Support process mining and patient journey analysis.
* Prepare reliable data for dashboards and visualization.

---

# 2. Technology Stack

| Technology      | Purpose                                        |
| --------------- | ---------------------------------------------- |
| Google BigQuery | Cloud data warehouse                           |
| SQL             | Data transformation and analysis               |
| dbt             | Data modeling, testing and documentation       |
| Python          | Data analysis and transition-time calculations |
| Power BI        | Dashboard and visualization                    |
| Git             | Version control                                |
| GitHub          | Project collaboration and code management      |

---

# 3. Project Architecture

```text
Hospital Event Data
        ↓
Google BigQuery
        ↓
Raw Data Layer
        ↓
Staging Layer
        ↓
Intermediate Layer
        ↓
Mart Layer
        ↓
Process Mining Analysis
        ↓
Power BI Dashboard
```

---

# 4. BigQuery Data Architecture

The project uses different layers for organizing and transforming the data.

```text
careflow-process-mining
│
├── careflow_raw
│
├── careflow_staging
│
└── careflow_mart
```

### Raw Layer

Contains the original hospital event data loaded into BigQuery.

### Staging Layer

Contains cleaned and prepared data used as input for transformation models.

### Intermediate Layer

Contains transformed models used for process analysis, including normalized and ordered patient events.

### Mart Layer

Contains business-ready models and KPIs for reporting and dashboard analysis.

---

# 5. dbt Project Structure

```text
careflow_dbt/
│
├── dbt_project.yml
│
├── models/
│   │
│   ├── staging/
│   │   └── stg_hospital_event_log.sql
│   │
│   ├── intermediate/
│   │   ├── int_normalized_event_log.sql
│   │   ├── int_ordered_events.sql
│   │   └── schema.yml
│   │
│   └── marts/
│       └── ...
│
├── tests/
├── macros/
├── seeds/
└── README.md
```

---

# 6. Data Pipeline Work Completed

## Day 1 – BigQuery Dataset

### Objective

Create the required BigQuery datasets for the CareFlow project.

### Work Completed

* Created the CareFlow Google Cloud project.
* Created the required BigQuery datasets.
* Organized the project into raw, staging and mart layers.

### Commit

```text
feat: create bigquery datasets
```

---

# Day 2 – Raw Table

### Objective

Create the raw hospital event table.

### Work Completed

* Created the raw hospital event table.
* Defined the required columns and data types.
* Prepared the table for loading hospital event data.

### Commit

```text
feat: create raw table
```

---

# Day 3 – Load Event Data

### Objective

Load hospital event data into BigQuery.

### Work Completed

* Loaded the hospital event log into BigQuery.
* Stored the original event data in the raw layer.
* Verified that the data was successfully loaded.

### Commit

```text
feat: load event log
```

---

# Day 4 – Schema Validation

### Objective

Validate the structure of the loaded hospital event data.

### Work Completed

* Checked column names.
* Checked data types.
* Verified event and patient identifiers.
* Validated timestamp fields.
* Checked the loaded data structure.

### Commit

```text
test: validate raw schema
```

---

# Day 5 – Initial Data Cleaning

### Objective

Perform initial cleaning and preparation of the hospital event data.

### Work Completed

* Checked for missing values.
* Checked duplicate records.
* Validated patient and event identifiers.
* Prepared the data for dbt transformation.
* Performed initial SQL-based data cleaning.

### Commit

```text
feat: initial data cleaning
```

---

# Day 6 – dbt Configuration

### Objective

Configure dbt for the CareFlow project.

### Work Completed

* Created the dbt project.
* Configured the BigQuery adapter.
* Configured the development profile.
* Connected dbt with the CareFlow BigQuery project.
* Verified the dbt connection.

### Validation

```bash
dbt debug
```

### Commit

```text
feat: configure dbt project
```

---

# Day 7 – Staging Model

### Objective

Create the staging model for the hospital event data.

### Work Completed

* Created the staging model.
* Selected the required hospital event columns.
* Prepared the raw data for downstream transformations.
* Added dbt model documentation and tests.

### Model

```text
stg_hospital_event_log
```

### Commit

```text
feat: create staging model
```

---

# Day 8 – Normalized Event Model

### Objective

Create a normalized intermediate model from the staging data.

### Work Completed

* Created the normalized hospital event model.
* Standardized event-related fields.
* Added waiting-time classification.
* Added rework classification.
* Added activity priority.
* Prepared the event data for process analysis.

### Model

```text
int_normalized_event_log
```

### Important Columns

```text
Event_ID
Patient_ID
Activity
event_timestamp
wait_category
rework_status
activity_priority
```

### Commit

```text
feat: create normalized event model
```

---

# Day 9 – dbt Model Testing

### Objective

Validate the dbt transformation models.

### Work Completed

* Added data quality tests.
* Tested required fields for NULL values.
* Validated dbt model execution.
* Checked transformation results in BigQuery.
* Fixed model and schema issues where required.

### Commands

```bash
dbt parse
dbt run
dbt test
dbt build
```

### Commit

```text
test: validate dbt model
```

---

# Day 10 – Documentation

### Objective

Document the CareFlow dbt models and data pipeline.

### Work Completed

* Added model descriptions.
* Added column descriptions.
* Documented data transformations.
* Documented dbt testing.
* Updated project README documentation.
* Prepared the project for process transition analysis.

### Commit

```text
docs: add dbt documentation
```

---

# Day 11 – Ordered Event Model

## Objective

Create an ordered event model to arrange hospital events chronologically for each patient.

## Work Completed

* Used `int_normalized_event_log` as the input model.
* Grouped events using `Patient_ID`.
* Ordered events using `event_timestamp`.
* Used `Event_ID` as a secondary ordering condition.
* Used the SQL `ROW_NUMBER()` window function.
* Assigned a sequential event order to each patient's journey.
* Added schema documentation and data quality tests.
* Validated the model using dbt and BigQuery.

## Ordering Logic

```text
Patient_ID
     ↓
event_timestamp
     ↓
Event_ID
     ↓
ROW_NUMBER()
     ↓
event_order
```

The event order starts from `1` for every patient.

### Example

| Patient_ID | Activity     | event_timestamp | event_order |
| ---------- | ------------ | --------------- | ----------: |
| P001       | Registration | 09:00           |           1 |
| P001       | Consultation | 09:30           |           2 |
| P001       | Diagnosis    | 10:15           |           3 |
| P001       | Treatment    | 11:00           |           4 |
| P002       | Registration | 09:10           |           1 |
| P002       | Consultation | 09:45           |           2 |

## SQL Technique Used

The model uses:

```sql
ROW_NUMBER() OVER (
    PARTITION BY Patient_ID
    ORDER BY event_timestamp, Event_ID
)
```

This creates a chronological sequence of activities for every patient.

## Model Created

```text
models/intermediate/
└── int_ordered_events.sql
```

## Output Columns

| Column            | Description                                    |
| ----------------- | ---------------------------------------------- |
| Event_ID          | Unique event identifier                        |
| Patient_ID        | Patient identifier                             |
| Activity          | Clinical activity                              |
| event_timestamp   | Clinical event timestamp                       |
| wait_category     | Waiting time classification                    |
| rework_status     | Rework classification                          |
| activity_priority | Activity priority                              |
| event_order       | Sequential order of the event for each patient |

## Day 11 Schema

The `schema.yml` file contains documentation and tests for:

```text
int_normalized_event_log
int_ordered_events
```

Important tests include:

```text
not_null(Event_ID)
not_null(Patient_ID)
not_null(Activity)
not_null(event_timestamp)
not_null(event_order)
```

## dbt Validation

The following commands were used:

```bash
dbt parse
dbt run --select int_ordered_events
dbt test --select int_ordered_events
dbt build --select int_ordered_events
```

The model was successfully validated before committing the changes.

## BigQuery Output

```text
Project:
careflow-process-mining

Dataset:
careflow_staging

Table:
int_ordered_events
```

## GitHub Files

The following files were created or updated for Day 11:

```text
README.md
models/intermediate/int_ordered_events.sql
models/intermediate/schema.yml
```

## GitHub Commit

```text
feat: create ordered event model
```

---

# 7. Current Data Flow After Day 11

```text
stg_hospital_event_log
          ↓
int_normalized_event_log
          ↓
int_ordered_events
          ↓
Activity Sequence
          ↓
Next: Transition Pair Generation
```

---

# 8. Process Mining Preparation

The ordered event model prepares the data for the next stage of process mining.

For example:

```text
Patient P001

Registration
     ↓
Consultation
     ↓
Diagnosis
     ↓
Treatment
     ↓
Discharge
```

These ordered activities will be used to generate transition pairs such as:

```text
Registration → Consultation
Consultation → Diagnosis
Diagnosis → Treatment
Treatment → Discharge
```

---

# 9. Next Planned Work

After Day 11, the next stages include:

| Day | Planned Work                                  |
| --: | --------------------------------------------- |
|  12 | Generate activity transition pairs            |
|  13 | Calculate transition times                    |
|  14 | Calculate average transition times            |
|  15 | Identify process bottlenecks                  |
|  16 | Prepare dashboard bottleneck data             |
|  17 | Define dashboard KPIs                         |
|  18 | Generate actual patient journeys              |
|  19 | Perform conformance analysis                  |
|  20 | Finalize process mining outputs and dashboard |

---

# 10. Project Status

```text
Day 1   ✅ BigQuery datasets
Day 2   ✅ Raw table
Day 3   ✅ Event data loading
Day 4   ✅ Schema validation
Day 5   ✅ Initial cleaning
Day 6   ✅ dbt configuration
Day 7   ✅ Staging model
Day 8   ✅ Normalized event model
Day 9   ✅ dbt testing
Day 10  ✅ Documentation
Day 11  ✅ Ordered event model
```

**Current Status: Day 11 Completed ✅**

The project is now ready for **activity transition pair generation and transition-time analysis**.

