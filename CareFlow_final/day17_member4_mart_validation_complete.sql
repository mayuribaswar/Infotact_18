-- =========================================================
-- CAREFLOW - DAY 17
-- MART LAYER VALIDATION
-- =========================================================


-- =========================================================
-- 1. DIM PATIENTS
-- =========================================================

-- Row Count
SELECT
    COUNT(*) AS patient_count
FROM `careflow-process-mining.careflow_mart.dim_patients`;


-- Patient Uniqueness
SELECT
    patient_id,
    COUNT(*) AS duplicate_count
FROM `careflow-process-mining.careflow_mart.dim_patients`
GROUP BY patient_id
HAVING COUNT(*) > 1;


-- NULL Patient IDs
SELECT
    COUNTIF(patient_id IS NULL) AS null_patient_id
FROM `careflow-process-mining.careflow_mart.dim_patients`;


-- =========================================================
-- 2. FACT HOSPITAL EVENTS
-- =========================================================

-- Row Count
SELECT
    COUNT(*) AS event_count
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`;


-- NULL Validation
SELECT
    COUNTIF(event_id IS NULL) AS null_event_id,
    COUNTIF(patient_id IS NULL) AS null_patient_id,
    COUNTIF(activity IS NULL) AS null_activity,
    COUNTIF(event_timestamp IS NULL) AS null_timestamp
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`;


-- Duplicate Event IDs
SELECT
    event_id,
    COUNT(*) AS duplicate_count
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
GROUP BY event_id
HAVING COUNT(*) > 1;


-- Activity Distribution
SELECT
    activity,
    COUNT(*) AS event_count
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
GROUP BY activity
ORDER BY event_count DESC;


-- =========================================================
-- 3. FACT → DIM RELATIONSHIP
-- =========================================================

SELECT
    COUNT(*) AS orphan_events
FROM `careflow-process-mining.careflow_mart.fct_hospital_events` e
LEFT JOIN `careflow-process-mining.careflow_mart.dim_patients` p
    ON e.patient_id = p.patient_id
WHERE p.patient_id IS NULL;


-- =========================================================
-- 4. PATIENT EVENT COUNT
-- =========================================================

SELECT
    patient_id,
    COUNT(*) AS total_events
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
GROUP BY patient_id
ORDER BY total_events DESC
LIMIT 20;

-- =========================================================
-- CAREFLOW - DAY 17
-- MEMBER 4 - COMPLETE MART / POWER BI VALIDATION
-- =========================================================
-- Purpose:
-- Validate the MART layer before using it in Power BI.
-- Checks covered:
-- 1. Dimension row count and key quality
-- 2. Fact row count and required fields
-- 3. Duplicate event IDs
-- 4. Fact -> dimension orphan records
-- 5. Activity distribution
-- 6. Patient event counts
-- 7. Event timestamp quality
-- 8. Patient event ordering
-- 9. Power BI-ready validation summary
-- =========================================================


-- =========================================================
-- 5. EVENT TIMESTAMP QUALITY
-- =========================================================

-- Future timestamps
SELECT
    COUNTIF(event_timestamp > CURRENT_TIMESTAMP()) AS future_events
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`;


-- Timestamp range
SELECT
    MIN(event_timestamp) AS first_event_timestamp,
    MAX(event_timestamp) AS last_event_timestamp
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`;


-- =========================================================
-- 6. PATIENT EVENT ORDERING
-- =========================================================

-- Check whether any patient has events with the same timestamp.
-- Same timestamps are not automatically errors, but they should
-- be reviewed before process analysis.
SELECT
    patient_id,
    event_timestamp,
    COUNT(*) AS events_at_same_timestamp
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
GROUP BY patient_id, event_timestamp
HAVING COUNT(*) > 1
ORDER BY events_at_same_timestamp DESC;


-- =========================================================
-- 7. PATIENT EVENT SUMMARY
-- =========================================================

SELECT
    patient_id,
    MIN(event_timestamp) AS first_event,
    MAX(event_timestamp) AS last_event,
    COUNT(*) AS total_events,
    TIMESTAMP_DIFF(
        MAX(event_timestamp),
        MIN(event_timestamp),
        MINUTE
    ) AS patient_process_duration_minutes
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
GROUP BY patient_id
ORDER BY patient_process_duration_minutes DESC;


-- =========================================================
-- 8. POWER BI DATASET READINESS
-- =========================================================

-- Basic completeness summary.
-- All NULL counts should be 0 for a clean dashboard dataset.
SELECT
    COUNT(*) AS total_events,
    COUNT(DISTINCT event_id) AS distinct_event_ids,
    COUNT(DISTINCT patient_id) AS distinct_patients,
    COUNT(DISTINCT activity) AS distinct_activities,
    COUNTIF(event_id IS NULL) AS null_event_ids,
    COUNTIF(patient_id IS NULL) AS null_patient_ids,
    COUNTIF(activity IS NULL) AS null_activities,
    COUNTIF(event_timestamp IS NULL) AS null_timestamps
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`;


-- =========================================================
-- 9. FINAL VALIDATION CHECKS
-- =========================================================

-- Duplicate patient IDs in dimension
SELECT
    COUNT(*) AS duplicate_patient_key_groups
FROM (
    SELECT
        patient_id
    FROM `careflow-process-mining.careflow_mart.dim_patients`
    GROUP BY patient_id
    HAVING COUNT(*) > 1
);


-- Duplicate event IDs in fact
SELECT
    COUNT(*) AS duplicate_event_id_groups
FROM (
    SELECT
        event_id
    FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
    GROUP BY event_id
    HAVING COUNT(*) > 1
);


-- Orphan events
SELECT
    COUNT(*) AS orphan_events
FROM `careflow-process-mining.careflow_mart.fct_hospital_events` e
LEFT JOIN `careflow-process-mining.careflow_mart.dim_patients` p
    ON e.patient_id = p.patient_id
WHERE p.patient_id IS NULL;


-- =========================================================
-- 10. MEMBER 4 SIGN-OFF CHECK
-- =========================================================
-- Expected for a clean MART layer:
-- duplicate_patient_key_groups = 0
-- duplicate_event_id_groups   = 0
-- orphan_events               = 0
-- null_event_ids              = 0
-- null_patient_ids            = 0
-- null_activities             = 0
-- null_timestamps             = 0
-- =========================================================
