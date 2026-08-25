# CareFlow – Raw Data Documentation

## 1. Dataset Overview

The CareFlow raw dataset is a simulated hospital workflow event log. It records individual events that occur during patient visits and is intended to be the starting point for the CareFlow process-mining pipeline.

**This document describes the RAW dataset exactly as received, before data cleaning or transformation.**

- Total rows: **10,013**
- Total columns: **12**
- Duplicate rows: **262**
- Duplicate Event_ID values: **300**
- Missing values: **290**

## 2. Raw Columns

| Column | Type | Description |
|---|---|---|
| `Event_ID` | Text | Unique identifier intended for each workflow event. |
| `Case_ID` | Text | Identifier for a patient's care case/visit workflow. |
| `Patient_ID` | Text | Identifier for the patient associated with the case. |
| `Visit_Type` | Text | Type of visit: OPD, IPD, or Emergency. |
| `Activity` | Text | Hospital activity performed during the workflow. |
| `Department` | Text | Hospital department responsible for the activity. |
| `Timestamp` | Date/Time text | Date and time at which the event occurred. |
| `Doctor_ID` | Text | Identifier of the doctor associated with the event. |
| `Severity` | Text | Patient/event severity classification. |
| `Waiting_Time_Minutes` | Integer | Waiting time recorded for the event, in minutes. |
| `Cost` | Integer | Cost recorded for the event. |
| `Status` | Text | Completion status of the event. |

## 3. Raw Data Values

### Visit Type

- OPD: **3,256**
- IPD: **3,501**
- Emergency: **3,256**

### Activity

| Activity | Records |
|---|---:|
| Doctor Consultation | 1,377 |
| Monitoring | 1,035 |
| Waiting | 1,028 |
| Patient Arrival | 1,027 |
| Discharged | 1,027 |
| Billing | 1,024 |
| Registration | 953 |
| Diagnosis | 939 |
| Treatment | 928 |
| Lab Test | 336 |
| ICU | 99 |
| doctor consultation | 40 |
| Lab test | 40 |
| LAB TEST | 40 |
| Doctor consultation | 40 |
| registration | 40 |
| REGISTRATION | 40 |

### Department

The raw file contains department names with inconsistent capitalization/spacing. For example, `Reception` and ` Reception ` both occur.

| Department | Records |
|---|---:|
| `Reception` | 4,077 |
| `Clinical` | 2,374 |
| `Ward` | 1,026 |
| `Billing` | 1,010 |
| `Treatment` | 912 |
| `Laboratory` | 415 |
| `ICU` | 99 |
| ` Reception ` | 38 |
| ` Clinical ` | 22 |
| ` Treatment ` | 16 |
| ` Billing ` | 14 |
| ` Ward ` | 9 |
| ` Laboratory ` | 1 |

### Status

- `Completed`: **9,953**
- `Done`: **60**

### Severity

- `Low`: **2,699**
- `Critical`: **2,442**
- `Medium`: **2,431**
- `High`: **2,321**
- `nan`: **120**

## 4. Raw Data Quality Findings

The raw dataset intentionally contains quality issues that should be addressed during the validation and cleaning stages.

| Check | Raw Result |
|---|---:|
| Total rows | 10,013 |
| Duplicate rows | 262 |
| Duplicate Event_ID values | 300 |
| Missing Timestamp values | 50 |
| Missing Doctor_ID values | 120 |
| Missing Severity values | 120 |
| Negative waiting times | 80 |

### Inconsistent activity names

The same activity appears in different forms, including:

- `Doctor Consultation`
- `doctor consultation`
- `Doctor consultation`
- `Lab Test`
- `Lab test`
- `LAB TEST`
- `Registration`
- `registration`
- `REGISTRATION`

These should be standardized before process discovery.

### Inconsistent department formatting

Several department values contain unnecessary leading/trailing spaces, such as:

- ` Reception `
- ` Clinical `
- ` Treatment `
- ` Billing `
- ` Ward `
- ` Laboratory `

### Inconsistent status values

The raw dataset contains both:

- `Completed`
- `Done`

These should be standardized to one status value during cleaning.

## 5. Numeric Ranges

- `Waiting_Time_Minutes`: **-5 to 30 minutes**
- `Cost`: **200 to 5000**

The raw dataset contains **80 negative waiting-time records**, which require correction or investigation.

## 6. Intended Raw Data Pipeline

The raw dataset is the input to the following CareFlow pipeline:

**Raw CSV → BigQuery Raw Table → dbt Cleaning/Staging → Normalized Event Log → PM4Py → Process Map / DFG**

## 7. Data Cleaning Required

Before using the data for final process-mining analysis, the following should be performed:

1. Remove or investigate duplicate records.
2. Ensure `Event_ID` is unique.
3. Handle missing timestamps.
4. Handle missing doctor IDs.
5. Handle missing severity values.
6. Correct negative waiting times.
7. Standardize activity names.
8. Trim department whitespace.
9. Standardize status values.
10. Validate chronological event ordering within each `Case_ID`.

## 8. Important Note

This is **simulated hospital data** created for the CareFlow academic/project workflow. It does not represent real patient records and should not be interpreted as real clinical data.
