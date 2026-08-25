# CareFlow – Clinical Process Mining

## 1. Project Overview

CareFlow is a Clinical Process Mining project designed to analyze hospital patient event data and understand the complete healthcare process followed by patients.

The cleaned dataset contains patient information, clinical information, hospital activities, timestamps, resource information, waiting time, service time, process duration, rework indicators, and financial information.

The project currently uses Google BigQuery for data storage and dbt for data transformation and modeling.

The transformed data is prepared for process analysis, bottleneck identification, patient-flow analysis, and future dashboard development.

---

## 2. Problem Statement

Hospitals generate large amounts of data during patient admission, diagnosis, treatment, and discharge.

This data contains multiple events performed by different departments and healthcare resources.

Analyzing this information manually makes it difficult to identify:

* Patient process flows
* Delays
* Waiting-time bottlenecks
* Repeated activities
* Department performance
* Resource utilization
* Process duration
* Patient outcomes

CareFlow organizes the hospital event data into structured analytical models so that healthcare processes can be analyzed systematically.

---

## 3. Project Objectives

The main objectives of CareFlow are:

1. Store cleaned hospital event data in BigQuery.
2. Organize hospital events into a structured event log.
3. Transform the data using dbt.
4. Create staging, intermediate, dimension, and fact models.
5. Analyze patient activity sequences.
6. Identify waiting-time and service-time patterns.
7. Identify process delays and rework.
8. Analyze department and resource information.
9. Validate the transformed datasets.
10. Prepare the data for process mining and visualization.

---

## 4. Dataset Overview

The cleaned hospital event-log dataset contains **31 columns**.

The dataset includes the following categories of information:

### Event Information

* Event_ID
* Activity
* Activity_Status
* Timestamp
* Event_Order

### Patient Information

* Patient_ID
* Patient_Name
* Age
* Gender
* Disease
* Severity
* Patient_Type

### Hospital Information

* Department
* Ward
* Bed_Number

### Doctor Information

* Doctor_ID
* Doctor_Name
* Shift
* Resource

### Process Information

* Wait_Time_Minutes
* Service_Time_Minutes
* Total_Process_Time
* Rework_Flag
* Previous_Activity
* Next_Activity
* Delay_Reason

### Admission and Outcome Information

* Admission_Date
* Discharge_Date
* Outcome

### Financial Information

* Total_Bill

---

## 5. Technology Stack

### Cloud Platform

* Google Cloud Platform
* Google BigQuery

### Data Transformation

* dbt

### Query Language

* SQL

### Programming

* Python

### Version Control

* Git
* GitHub

### Development Environment

* Visual Studio Code
* Command Prompt / Terminal

---

## 6. Data Pipeline

The current CareFlow pipeline follows:

```text
Cleaned Hospital Dataset
          ↓
      BigQuery
          ↓
      Raw Table
          ↓
    dbt Staging
          ↓
  Intermediate Model
          ↓
   ┌──────┴──────┐
   ↓             ↓
Dimension       Fact
  Models        Models
   └──────┬──────┘
          ↓
      Validation
          ↓
   Process Analysis
```

---

## 7. Data Architecture

The project follows a layered data architecture.

### Layer 1 – Cleaned Source Data

The cleaned hospital event-log dataset is used as the input.

### Layer 2 – BigQuery

The cleaned data is stored in Google BigQuery.

### Layer 3 – Staging

The staging layer standardizes and prepares the source data.

### Layer 4 – Intermediate

The intermediate layer performs process-level transformations.

### Layer 5 – Mart

The mart layer contains analytics-ready dimension and fact tables.

### Layer 6 – Analysis

The final transformed data can be used for:

* Process mining
* Patient-flow analysis
* Waiting-time analysis
* Department analysis
* Rework analysis
* Outcome analysis
* Dashboard development

---

## 8. Event Log Structure

The dataset follows an event-log structure.

Each event represents an activity associated with a patient.

The basic process structure is:

```text
Patient
   ↓
Event
   ↓
Activity
   ↓
Timestamp
   ↓
Previous / Next Activity
   ↓
Process Analysis
```

`Event_ID` uniquely identifies an event, while `Patient_ID` connects multiple events belonging to the same patient.

`Event_Order` helps identify the sequence in which activities occur.

---

## 9. Patient Process Example

A patient's process can be represented as:

```text
Admission
   ↓
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

The actual sequence depends on the events recorded for each patient.

The fields `Previous_Activity` and `Next_Activity` help understand transitions between activities.

---

## 10. Process-Time Analysis

CareFlow contains three important time-related measures:

### Wait_Time_Minutes

Represents the waiting time before an activity or service.

### Service_Time_Minutes

Represents the time spent performing the activity/service.

### Total_Process_Time

Represents the overall process time associated with the event/process.

These fields can be used to identify bottlenecks and delays.

---

## 11. Rework Analysis

The `Rework_Flag` identifies whether an activity or process requires rework.

A rework event can indicate:

* Repeated activity
* Additional processing
* Correction
* Repeated treatment or procedure

Rework analysis can help identify inefficient process paths.

---

## 12. Delay Analysis

The `Delay_Reason` field provides information about the reason for process delays.

It can be used together with:

* Wait_Time_Minutes
* Department
* Resource
* Activity
* Shift

to identify potential causes of delays.

---

## 13. Resource Analysis

The dataset contains resource-related fields:

* Doctor_ID
* Doctor_Name
* Shift
* Resource
* Department
* Ward
* Bed_Number

These fields can be used to analyze resource allocation and workload.

---

## 14. Patient Analysis

Patient-related fields include:

* Patient_ID
* Patient_Name
* Age
* Gender
* Disease
* Severity
* Patient_Type

These fields allow analysis based on patient characteristics.

---

## 15. Admission and Discharge Analysis

The following fields represent the patient's hospital stay:

* Admission_Date
* Discharge_Date
* Outcome

These fields can be used to analyze:

* Hospital stay duration
* Patient outcomes
* Admission patterns
* Discharge patterns

---

## 16. Financial Analysis

The `Total_Bill` field represents the total bill associated with the patient/process.

It can later be used for:

* Cost analysis
* Patient-type comparison
* Disease-wise cost analysis
* Department-wise billing analysis

---

## 17. dbt Models

The current dbt transformation flow is:

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

## 18. Data Validation

The transformed data is validated using SQL and dbt validation checks.

Validation includes:

* Record count
* NULL values
* Duplicate events
* Event_ID uniqueness
* Patient_ID consistency
* Timestamp validation
* Event order validation
* Waiting-time validation
* Service-time validation
* Process-time validation
* Rework validation
* Date validation
* Financial validation

---

## 19. Current Project Status

The current completed work includes:

* Cleaned dataset preparation
* BigQuery setup
* Data loading
* Raw table creation
* dbt setup
* dbt configuration
* Staging transformation
* Intermediate transformation
* Dimension model
* Fact model
* Data validation
* Documentation

---

## 20. Current Outcome

The cleaned hospital event-log data has been organized into a structured cloud data pipeline.

The data is prepared for further process-mining and analytical activities.

The current dataset supports analysis of:

* Patient processes
* Activity sequences
* Waiting times
* Service times
* Process duration
* Rework
* Delays
* Resources
* Departments
* Patient outcomes
* Hospital billing

---

## 21. Future Scope

Future work can include:

* Process discovery
* Process-flow visualization
* Bottleneck detection
* Department performance analysis
* Resource utilization analysis
* Patient journey analysis
* Power BI dashboard
* Advanced process mining
* Predictive analytics
* Machine learning-based delay prediction

---

## 22. Conclusion

CareFlow provides a structured approach to analyzing hospital event-log data.

The cleaned dataset combines patient, clinical, process, resource, timing, outcome, and billing information.

Using BigQuery and dbt, the project transforms the cleaned data into structured analytical models that can support healthcare process analysis and future visualization.
