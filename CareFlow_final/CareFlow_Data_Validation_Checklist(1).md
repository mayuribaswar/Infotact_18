# CareFlow Data Validation Checklist

## Purpose

This checklist is used to validate the CareFlow hospital event log before it moves through the BigQuery, dbt, and PM4Py pipeline.

## Day 2 – Member 4

### 1. Required Columns
- [ ] `case_id` exists
- [ ] `patient_id` exists
- [ ] `activity` exists
- [ ] `timestamp` exists

### 2. Missing Values
- [ ] Check for missing `case_id`
- [ ] Check for missing `patient_id`
- [ ] Check for missing `activity`
- [ ] Check for missing `timestamp`

### 3. Duplicate Records
- [ ] Check for completely duplicated rows
- [ ] Check for duplicate events for the same case
- [ ] Investigate unexpected duplicate records

### 4. ID Validation
- [ ] Each event has a valid `case_id`
- [ ] Each event has a valid `patient_id`
- [ ] Case IDs are consistently formatted
- [ ] Patient IDs are consistently formatted

### 5. Timestamp Validation
- [ ] All timestamps use a valid date-time format
- [ ] No invalid timestamps exist
- [ ] Events within each case are ordered chronologically

### 6. Activity Validation
Expected activities may include:
- Registration
- Consultation
- Lab Test
- Diagnosis
- Treatment
- Discharge

- [ ] Activity names are consistent
- [ ] No unexpected activity names exist
- [ ] Activities are not empty

### 7. Event Sequence Validation
- [ ] Each case contains a valid workflow
- [ ] Registration occurs before major clinical activities
- [ ] Discharge occurs after treatment
- [ ] Loop-back activities are correctly represented
- [ ] No impossible event sequences are present

### 8. Final Validation
- [ ] CSV structure is valid
- [ ] Record count is documented
- [ ] Missing-value count is documented
- [ ] Duplicate count is documented
- [ ] Data is ready for BigQuery ingestion
- [ ] Validation results are recorded

## Validation Result

**Status:** Pending

**Validated by:** Member 4

**Date:** __________________

**Notes:**  
__________________________________________________  
__________________________________________________

