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

### Next Step

**Day 2 — Create the raw hospital event table.**
