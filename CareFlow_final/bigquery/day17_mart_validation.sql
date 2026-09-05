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