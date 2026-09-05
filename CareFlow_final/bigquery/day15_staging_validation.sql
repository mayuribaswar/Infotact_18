-- =========================================================
-- CAREFLOW - DAY 15
-- STAGING LAYER VALIDATION
-- =========================================================


-- 1. Row Count
SELECT
    COUNT(*) AS staging_row_count
FROM `careflow-process-mining.careflow_staging.stg_hospital_event_log`;


-- 2. NULL Validation
SELECT
    COUNTIF(event_id IS NULL) AS null_event_id,
    COUNTIF(patient_id IS NULL) AS null_patient_id,
    COUNTIF(activity IS NULL) AS null_activity,
    COUNTIF(event_timestamp IS NULL) AS null_event_timestamp
FROM `careflow-process-mining.careflow_staging.stg_hospital_event_log`;


-- 3. Duplicate Event ID
SELECT
    event_id,
    COUNT(*) AS duplicate_count
FROM `careflow-process-mining.careflow_staging.stg_hospital_event_log`
GROUP BY event_id
HAVING COUNT(*) > 1;


-- 4. Activity Validation
SELECT
    activity,
    COUNT(*) AS event_count
FROM `careflow-process-mining.careflow_staging.stg_hospital_event_log`
GROUP BY activity
ORDER BY event_count DESC;


-- 5. Timestamp Validation
SELECT
    COUNT(*) AS invalid_timestamp_count
FROM `careflow-process-mining.careflow_staging.stg_hospital_event_log`
WHERE event_timestamp IS NULL;


-- 6. Patient Count
SELECT
    COUNT(DISTINCT patient_id) AS unique_patients
FROM `careflow-process-mining.careflow_staging.stg_hospital_event_log`;


-- 7. Event Date Range
SELECT
    MIN(event_timestamp) AS first_event,
    MAX(event_timestamp) AS last_event
FROM `careflow-process-mining.careflow_staging.stg_hospital_event_log`;