# CareFlow Architecture

## System Architecture

```text
                ┌──────────────────────┐
                │   Python EHR Data    │
                │      Generator       │
                └──────────┬───────────┘
                           │
                           ▼
                ┌──────────────────────┐
                │      CSV Event       │
                │         Log          │
                └──────────┬───────────┘
                           │
                           ▼
                ┌──────────────────────┐
                │      BigQuery        │
                │     Raw Events       │
                └──────────┬───────────┘
                           │
                           ▼
                ┌──────────────────────┐
                │        dbt           │
                │ Cleaning &           │
                │ Transformation       │
                └──────────┬───────────┘
                           │
                           ▼
                ┌──────────────────────┐
                │   Clean Event Log    │
                │ Case ID | Activity   │
                │ Timestamp | Patient  │
                └──────────┬───────────┘
                           │
                           ▼
                ┌──────────────────────┐
                │       PM4Py          │
                │ Process Discovery    │
                └──────────┬───────────┘
                           │
                           ▼
                ┌──────────────────────┐
                │ Process Map / DFG    │
                │ + Process Analysis   │
                └──────────────────────┘
```

## Components

### 1. Python EHR Generator
Generates simulated hospital patient events such as registration, consultation, lab tests, diagnosis, treatment, and discharge.

### 2. CSV Event Log
Stores the generated events in a structured format before loading them into BigQuery.

### 3. BigQuery
Stores the raw event data and provides a scalable environment for querying and data processing.

### 4. dbt
Cleans, validates, and transforms raw BigQuery data into a standardized event log.

### 5. Clean Event Log
The process-mining dataset contains key fields such as:
- `case_id`
- `patient_id`
- `activity`
- `timestamp`

### 6. PM4Py
Uses the cleaned event log to perform process discovery and process analysis.

### 7. Process Map / Directly-Follows Graph
Visualizes how patients move through the hospital workflow and helps identify repeated activities and loop-backs.

## Overall Data Flow

**Python EHR → CSV → BigQuery → dbt → Clean Event Log → PM4Py → Process Map / DFG**

## Member 4 – Day 1 Deliverable

Create and maintain the project architecture documentation and ensure that the complete data flow between all components is clearly documented.

**GitHub Commit:**
`docs: create project architecture`
