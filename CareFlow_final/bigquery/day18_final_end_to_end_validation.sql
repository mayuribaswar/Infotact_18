-- =========================================================
-- CAREFLOW - DAY 18
-- FINAL END-TO-END VALIDATION
-- =========================================================


-- =========================================================
-- 1. RAW VS STAGING
-- =========================================================

SELECT
    'RAW' AS layer,
    COUNT(*) AS record_count
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`

UNION ALL

SELECT
    'STAGING' AS layer,
    COUNT(*) AS record_count
FROM `careflow-process-mining.careflow_staging.stg_hospital_event_log`;


-- =========================================================
-- 2. STAGING VS MART
-- =========================================================

SELECT
    'STAGING' AS layer,
    COUNT(*) AS record_count
FROM `careflow-process-mining.careflow_staging.stg_hospital_event_log`

UNION ALL

SELECT
    'MART' AS layer,
    COUNT(*) AS record_count
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`;


-- =========================================================
-- 3. UNIQUE PATIENT RECONCILIATION
-- =========================================================

SELECT
    'STAGING' AS layer,
    COUNT(DISTINCT patient_id) AS unique_patients
FROM `careflow-process-mining.careflow_staging.stg_hospital_event_log`

UNION ALL

SELECT
    'MART' AS layer,
    COUNT(DISTINCT patient_id) AS unique_patients
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`;


-- =========================================================
-- 4. FINAL NULL CHECK
-- =========================================================

SELECT
    COUNTIF(event_id IS NULL) AS null_event_id,
    COUNTIF(patient_id IS NULL) AS null_patient_id,
    COUNTIF(activity IS NULL) AS null_activity,
    COUNTIF(event_timestamp IS NULL) AS null_timestamp
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`;


-- =========================================================
-- 5. FINAL DUPLICATE CHECK
-- =========================================================

SELECT
    COUNT(*) AS duplicate_event_groups
FROM (
    SELECT
        event_id
    FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
    GROUP BY event_id
    HAVING COUNT(*) > 1
);


-- =========================================================
-- 6. FINAL ORPHAN CHECK
-- =========================================================

SELECT
    COUNT(*) AS orphan_events
FROM `careflow-process-mining.careflow_mart.fct_hospital_events` e
LEFT JOIN `careflow-process-mining.careflow_mart.dim_patients` p
    ON e.patient_id = p.patient_id
WHERE p.patient_id IS NULL;


-- =========================================================
-- 7. FINAL DATE RANGE
-- =========================================================

SELECT
    MIN(event_timestamp) AS first_event,
    MAX(event_timestamp) AS last_event
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`;


-- =========================================================
-- 8. FINAL ACTIVITY SUMMARY
-- =========================================================

SELECT
    activity,
    COUNT(*) AS event_count
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
GROUP BY activity
ORDER BY event_count DESC;


-- =========================================================
-- 9. FINAL PATIENT SUMMARY
-- =========================================================

SELECT
    COUNT(DISTINCT patient_id) AS total_patients,
    COUNT(*) AS total_events,
    COUNT(DISTINCT activity) AS total_activities
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`;