# CareFlow – dbt Models Documentation

## 1. Overview

dbt is used in the CareFlow project to transform the cleaned hospital event-log data stored in BigQuery.

The project uses a layered transformation approach consisting of:

* Source
* Staging
* Intermediate
* Mart

---

## 2. dbt Project

Project name:

```text
careflow_dbt
```

The current environment uses dbt for SQL-based transformations and model management.

---

## 3. Model Architecture

```text
hospital_event_log_raw
          ↓
stg_hospital_event_log
          ↓
int_patient_process
          ↓
     ┌────┴────┐
     ↓         ↓
dim_patients   fct_hospital_events
```

---

## 4. Source Table

### `hospital_event_log_raw`

The raw/cleaned hospital event-log table acts as the source for the dbt transformations.

The source contains:

* Event information
* Patient information
* Clinical information
* Department information
* Doctor information
* Process information
* Resource information
* Admission/discharge information
* Outcome information
* Billing information

---

## 5. Staging Model

### Model Name

```text
stg_hospital_event_log
```

### Purpose

The staging model prepares the source event data for downstream transformations.

### Main Responsibilities

* Read source data
* Standardize fields
* Maintain consistent data types
* Prepare event-level records
* Apply basic transformations
* Provide a clean input for intermediate models

### Important Fields

```text
Event_ID
Patient_ID
Activity
Department
Activity_Status
Timestamp
Event_Order
Wait_Time_Minutes
Service_Time_Minutes
Total_Process_Time
Rework_Flag
Previous_Activity
Next_Activity
```

---

## 6. Intermediate Model

### Model Name

```text
int_patient_process
```

### Purpose

The intermediate model prepares patient process information for analytical models.

### Main Responsibilities

* Organize patient events
* Maintain event sequence
* Prepare process-level information
* Support activity transition analysis
* Prepare data for mart models

### Process Structure

```text
Patient
   ↓
Event
   ↓
Activity
   ↓
Event_Order
   ↓
Previous Activity
   ↓
Next Activity
```

---

## 7. Dimension Model

### Model Name

```text
dim_patients
```

### Purpose

The dimension model provides patient-level information for analysis.

Possible attributes include:

```text
Patient_ID
Patient_Name
Age
Gender
Disease
Severity
Patient_Type
Department
```

The exact columns in the final model should follow the current SQL model definition.

---

## 8. Fact Model

### Model Name

```text
fct_hospital_events
```

### Purpose

The fact model stores hospital event-level information for analytical queries.

Important fields include:

```text
Event_ID
Patient_ID
Activity
Department
Activity_Status
Timestamp
Event_Order
Wait_Time_Minutes
Service_Time_Minutes
Total_Process_Time
Rework_Flag
Previous_Activity
Next_Activity
Delay_Reason
```

It can be used for:

* Event analysis
* Activity analysis
* Waiting-time analysis
* Service-time analysis
* Process-time analysis
* Rework analysis
* Process sequence analysis

---

## 9. Model Dependency

The model dependency is:

```text
Raw Source
    ↓
Staging
    ↓
Intermediate
    ↓
Dimension + Fact
```

---

## 10. dbt Commands

### Debug

```bash
dbt debug
```

Used to check dbt configuration and database connection.

### Parse

```bash
dbt parse
```

Used to validate the dbt project structure and parsing.

### Compile

```bash
dbt compile
```

Used to compile dbt models into SQL.

### Run

```bash
dbt run
```

Used to execute the transformation models.

### Test

```bash
dbt test
```

Used to execute configured data tests.

---

## 11. Model Validation

After running dbt, models should be validated for:

* Record count
* Required columns
* NULL values
* Duplicate events
* Event_ID uniqueness
* Patient_ID consistency
* Timestamp values
* Event_Order
* Waiting time
* Service time
* Process time
* Rework flags

---

## 12. dbt Benefits

Using dbt provides:

* Modular SQL transformations
* Clear dependencies
* Reusable models
* Data testing
* Documentation
* Version control
* Maintainable transformations
* Better project organization

---

## 13. Current dbt Status

The project currently includes:

* dbt project setup
* BigQuery connection
* Source configuration
* Staging model
* Intermediate model
* Dimension model
* Fact model
* Compilation
* Validation
