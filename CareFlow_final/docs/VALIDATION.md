# CareFlow – Data Validation Documentation

## 1. Overview

Data validation ensures that the cleaned hospital event-log data is accurate, consistent, and suitable for transformation and analysis.

Validation is performed across the BigQuery and dbt layers.

---

## 2. Validation Pipeline

```text
Cleaned Dataset
      ↓
Raw Table
      ↓
Staging Model
      ↓
Intermediate Model
      ↓
Dimension / Fact Models
      ↓
Validation
```

---

## 3. Record Count Validation

The total number of records should be checked after each major transformation.

```sql
SELECT COUNT(*) AS total_records
FROM `PROJECT.DATASET.TABLE`;
```

Record counts help identify unexpected data loss or duplication.

---

## 4. Event_ID Validation

`Event_ID` should identify individual events.

### NULL Check

```sql
SELECT COUNT(*) AS null_event_ids
FROM `PROJECT.DATASET.TABLE`
WHERE Event_ID IS NULL;
```

### Duplicate Check

```sql
SELECT
    Event_ID,
    COUNT(*) AS event_count
FROM `PROJECT.DATASET.TABLE`
GROUP BY Event_ID
HAVING COUNT(*) > 1;
```

Duplicate Event_ID values should be investigated.

---

## 5. Patient_ID Validation

Patient_ID is used to identify patients.

```sql
SELECT COUNT(*) AS null_patient_ids
FROM `PROJECT.DATASET.TABLE`
WHERE Patient_ID IS NULL;
```

Unique patients can be calculated using:

```sql
SELECT COUNT(DISTINCT Patient_ID) AS total_patients
FROM `PROJECT.DATASET.TABLE`;
```

---

## 6. Activity Validation

Activity is one of the most important process-mining fields.

### NULL Check

```sql
SELECT COUNT(*) AS null_activities
FROM `PROJECT.DATASET.TABLE`
WHERE Activity IS NULL;
```

### Activity Distribution

```sql
SELECT
    Activity,
    COUNT(*) AS activity_count
FROM `PROJECT.DATASET.TABLE`
GROUP BY Activity
ORDER BY activity_count DESC;
```

This identifies the most frequently performed activities.

---

## 7. Timestamp Validation

Timestamp values are checked to ensure that event dates are valid.

```sql
SELECT
    MIN(Timestamp) AS earliest_event,
    MAX(Timestamp) AS latest_event
FROM `PROJECT.DATASET.TABLE`;
```

Timestamp validation helps ensure correct event ordering.

---

## 8. Event_Order Validation

Event_Order represents the sequence of events.

A case-wise event sequence can be checked using:

```sql
SELECT
    Patient_ID,
    Event_Order,
    Activity
FROM `PROJECT.DATASET.TABLE`
ORDER BY Patient_ID, Event_Order;
```

This helps verify that activities occur in the expected order.

---

## 9. Waiting-Time Validation

Waiting time should be a valid non-negative value.

```sql
SELECT *
FROM `PROJECT.DATASET.TABLE`
WHERE Wait_Time_Minutes < 0;
```

Negative waiting times should be investigated.

---

## 10. Service-Time Validation

Service time should also be non-negative.

```sql
SELECT *
FROM `PROJECT.DATASET.TABLE`
WHERE Service_Time_Minutes < 0;
```

---

## 11. Total Process Time Validation

Total process time should contain valid values.

```sql
SELECT *
FROM `PROJECT.DATASET.TABLE`
WHERE Total_Process_Time < 0;
```

---

## 12. Rework Flag Validation

`Rework_Flag` is a BOOLEAN field.

The distribution can be checked using:

```sql
SELECT
    Rework_Flag,
    COUNT(*) AS event_count
FROM `PROJECT.DATASET.TABLE`
GROUP BY Rework_Flag;
```

Expected values are generally:

```text
TRUE
FALSE
```

---

## 13. Previous and Next Activity Validation

The process transition fields can be checked using:

```sql
SELECT
    Patient_ID,
    Event_Order,
    Previous_Activity,
    Activity,
    Next_Activity
FROM `PROJECT.DATASET.TABLE`
ORDER BY Patient_ID, Event_Order;
```

This helps verify the sequence of activities.

---

## 14. Admission and Discharge Validation

Admission and discharge dates should be checked for consistency.

Example:

```sql
SELECT *
FROM `PROJECT.DATASET.TABLE`
WHERE Discharge_Date < Admission_Date;
```

Records returned by this query should be investigated.

---

## 15. Age Validation

Age should contain valid values.

Example:

```sql
SELECT *
FROM `PROJECT.DATASET.TABLE`
WHERE Age < 0;
```

If an upper age limit is defined for the project, that should also be checked.

---

## 16. Total Bill Validation

The total bill should contain valid non-negative values.

```sql
SELECT *
FROM `PROJECT.DATASET.TABLE`
WHERE Total_Bill < 0;
```

---

## 17. NULL Validation

Important columns should be checked for NULL values.

```sql
SELECT
    COUNTIF(Event_ID IS NULL) AS null_event_id,
    COUNTIF(Patient_ID IS NULL) AS null_patient_id,
    COUNTIF(Activity IS NULL) AS null_activity,
    COUNTIF(Timestamp IS NULL) AS null_timestamp,
    COUNTIF(Department IS NULL) AS null_department
FROM `PROJECT.DATASET.TABLE`;
```

---

## 18. Department Validation

Department distribution can be checked using:

```sql
SELECT
    Department,
    COUNT(*) AS event_count
FROM `PROJECT.DATASET.TABLE`
GROUP BY Department
ORDER BY event_count DESC;
```

This helps identify the number of events handled by each department.

---

## 19. Activity Transition Validation

Activity transitions can be analyzed using:

```sql
SELECT
    Previous_Activity,
    Activity,
    Next_Activity,
    COUNT(*) AS transition_count
FROM `PROJECT.DATASET.TABLE`
GROUP BY
    Previous_Activity,
    Activity,
    Next_Activity
ORDER BY transition_count DESC;
```

This is useful for future process-mining analysis.

---

## 20. dbt Model Validation

The following dbt models are validated:

```text
stg_hospital_event_log
int_patient_process
dim_patients
fct_hospital_events
```

Validation includes:

* Model existence
* Record counts
* Required columns
* NULL checks
* Duplicate checks
* Data-type consistency
* Event sequence checks
* Process-time checks

---

## 21. Validation Checklist

* [ ] Dataset loaded successfully
* [ ] Record count verified
* [ ] Event_ID checked
* [ ] Duplicate Event_ID checked
* [ ] Patient_ID checked
* [ ] Activity checked
* [ ] Timestamp checked
* [ ] Event_Order checked
* [ ] Age checked
* [ ] Waiting time checked
* [ ] Service time checked
* [ ] Total process time checked
* [ ] Rework flag checked
* [ ] Previous activity checked
* [ ] Next activity checked
* [ ] Admission date checked
* [ ] Discharge date checked
* [ ] Total bill checked
* [ ] NULL values checked
* [ ] Department distribution checked
* [ ] dbt staging model checked
* [ ] dbt intermediate model checked
* [ ] Dimension model checked
* [ ] Fact model checked

---

## 22. Validation Outcome

The validation process ensures that the cleaned CareFlow hospital event-log data is structurally consistent and suitable for dbt transformation and further process analysis.

The validated dataset provides a reliable foundation for analyzing:

* Patient journeys
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
