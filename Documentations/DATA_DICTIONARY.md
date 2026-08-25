# CareFlow – Data Dictionary

## 1. Overview

This document describes the columns available in the cleaned CareFlow hospital event-log dataset.

The dataset contains **31 columns** covering event, patient, clinical, hospital, process, resource, admission, outcome, and financial information.

---

## 2. Complete Data Dictionary

| #  | Column Name          | Data Type | Mode     | Description                                                |
| -- | -------------------- | --------- | -------- | ---------------------------------------------------------- |
| 1  | Event_ID             | STRING    | NULLABLE | Unique identifier for each hospital event                  |
| 2  | Patient_ID           | STRING    | NULLABLE | Unique identifier of the patient                           |
| 3  | Patient_Name         | STRING    | NULLABLE | Name of the patient                                        |
| 4  | Age                  | INTEGER   | NULLABLE | Age of the patient                                         |
| 5  | Gender               | STRING    | NULLABLE | Gender of the patient                                      |
| 6  | Disease              | STRING    | NULLABLE | Disease or medical condition associated with the patient   |
| 7  | Severity             | STRING    | NULLABLE | Severity level of the patient's condition                  |
| 8  | Patient_Type         | STRING    | NULLABLE | Type/category of patient                                   |
| 9  | Department           | STRING    | NULLABLE | Hospital department associated with the event              |
| 10 | Activity             | STRING    | NULLABLE | Activity performed during the patient process              |
| 11 | Activity_Status      | STRING    | NULLABLE | Status of the activity                                     |
| 12 | Timestamp            | TIMESTAMP | NULLABLE | Date and time of the event                                 |
| 13 | Event_Order          | INTEGER   | NULLABLE | Sequential order of the event                              |
| 14 | Doctor_ID            | STRING    | NULLABLE | Unique identifier of the doctor                            |
| 15 | Doctor_Name          | STRING    | NULLABLE | Name of the doctor                                         |
| 16 | Shift                | STRING    | NULLABLE | Work shift associated with the event                       |
| 17 | Wait_Time_Minutes    | INTEGER   | NULLABLE | Waiting time associated with the activity                  |
| 18 | Service_Time_Minutes | INTEGER   | NULLABLE | Time spent performing the service/activity                 |
| 19 | Total_Process_Time   | INTEGER   | NULLABLE | Total time associated with the process                     |
| 20 | Rework_Flag          | BOOLEAN   | NULLABLE | Indicates whether rework occurred                          |
| 21 | Previous_Activity    | STRING    | NULLABLE | Activity performed immediately before the current activity |
| 22 | Next_Activity        | STRING    | NULLABLE | Activity performed immediately after the current activity  |
| 23 | Delay_Reason         | STRING    | NULLABLE | Reason associated with a process delay                     |
| 24 | Resource             | STRING    | NULLABLE | Resource used or associated with the activity              |
| 25 | Ward                 | STRING    | NULLABLE | Hospital ward associated with the patient/event            |
| 26 | Bed_Number           | STRING    | NULLABLE | Bed assigned to the patient                                |
| 27 | Admission_Date       | TIMESTAMP | NULLABLE | Date and time of patient admission                         |
| 28 | Discharge_Date       | TIMESTAMP | NULLABLE | Date and time of patient discharge                         |
| 29 | Outcome              | STRING    | NULLABLE | Outcome of the patient/process                             |
| 30 | Total_Bill           | INTEGER   | NULLABLE | Total bill amount associated with the patient/process      |

> **Note:** The supplied schema lists 30 named columns, not 31. The documentation above therefore follows the columns actually provided.

---

## 3. Event Information

### Event_ID

Unique identifier for an individual hospital event.

Used to distinguish one event from another.

### Activity

Represents the activity performed during the patient's healthcare journey.

### Activity_Status

Represents the current status of the activity.

### Timestamp

Stores the date and time when the event occurred.

### Event_Order

Represents the sequential position of an event in the patient's process.

---

## 4. Patient Information

### Patient_ID

Unique identifier assigned to a patient.

### Patient_Name

Name of the patient.

### Age

Age of the patient.

### Gender

Gender of the patient.

### Disease

Disease or medical condition associated with the patient.

### Severity

Represents the severity of the patient's condition.

### Patient_Type

Represents the category/type of patient.

---

## 5. Hospital Information

### Department

Identifies the hospital department where the activity occurs.

### Ward

Identifies the ward associated with the patient.

### Bed_Number

Identifies the bed assigned to the patient.

---

## 6. Doctor and Resource Information

### Doctor_ID

Unique identifier of the doctor.

### Doctor_Name

Name of the doctor.

### Shift

Represents the work shift associated with the event.

### Resource

Represents the resource associated with the activity.

---

## 7. Process-Time Information

### Wait_Time_Minutes

Represents the amount of time the patient waits before receiving the relevant service/activity.

### Service_Time_Minutes

Represents the amount of time spent performing the activity or service.

### Total_Process_Time

Represents the total process time associated with the event/process.

---

## 8. Process Sequence Information

### Previous_Activity

Represents the activity that occurred before the current activity.

### Next_Activity

Represents the activity that occurs after the current activity.

These fields are useful for process-flow and transition analysis.

---

## 9. Rework Information

### Rework_Flag

Boolean field indicating whether rework occurred.

Possible values:

```text
TRUE
FALSE
```

It can be used to identify repeated or inefficient process activities.

---

## 10. Delay Information

### Delay_Reason

Represents the reason for a delay in the process.

This field can be analyzed together with waiting time, department, resource, and activity.

---

## 11. Admission and Discharge

### Admission_Date

Records when the patient was admitted.

### Discharge_Date

Records when the patient was discharged.

These fields can be used to analyze hospital stay duration.

---

## 12. Outcome

### Outcome

Represents the final or recorded outcome associated with the patient/process.

---

## 13. Financial Information

### Total_Bill

Represents the total bill associated with the patient/process.

It can be used for financial and cost analysis.

---

## 14. Data Types

### STRING

Used for:

* IDs
* Names
* Categories
* Activities
* Departments
* Statuses

### INTEGER

Used for:

* Age
* Event_Order
* Waiting time
* Service time
* Process time
* Total bill

### TIMESTAMP

Used for:

* Timestamp
* Admission_Date
* Discharge_Date

### BOOLEAN

Used for:

* Rework_Flag

---

## 15. Primary Analytical Relationships

The important relationships are:

```text
Patient_ID
    ↓
Patient Events
    ↓
Event_ID
    ↓
Activity
    ↓
Event_Order
    ↓
Previous_Activity / Next_Activity
```

These relationships form the basis of process-mining analysis.
