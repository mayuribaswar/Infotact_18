-- =========================================================
-- CAREFLOW - DAY 16
-- INTERMEDIATE LAYER VALIDATION
-- =========================================================


-- =========================================================
-- 1. PATIENT PROCESS VALIDATION
-- =========================================================

-- Row Count
SELECT
    COUNT(*) AS patient_process_rows
FROM `careflow-process-mining.careflow_staging.int_patient_process`;


-- Patient Count
SELECT
    COUNT(DISTINCT patient_id) AS unique_patients
FROM `careflow-process-mining.careflow_staging.int_patient_process`;


-- NULL Validation
SELECT
    COUNTIF(patient_id IS NULL) AS null_patient_id,
    COUNTIF(activity IS NULL) AS null_activity,
    COUNTIF(event_timestamp IS NULL) AS null_timestamp
FROM `careflow-process-mining.careflow_staging.int_patient_process`;


-- Patient Event Ordering
SELECT
    patient_id,
    event_timestamp,
    LAG(event_timestamp) OVER (
        PARTITION BY patient_id
        ORDER BY event_timestamp
    ) AS previous_timestamp
FROM `careflow-process-mining.careflow_staging.int_patient_process`
QUALIFY previous_timestamp IS NOT NULL
    AND event_timestamp < previous_timestamp;


-- =========================================================
-- 2. ACTIVITY TRANSITIONS VALIDATION
-- =========================================================

-- Row Count
SELECT
    COUNT(*) AS transition_rows
FROM `careflow-process-mining.careflow_staging.int_activity_transitions`;


-- Transition Distribution
SELECT
    activity,
    next_activity,
    COUNT(*) AS transition_count
FROM `careflow-process-mining.careflow_staging.int_activity_transitions`
GROUP BY activity, next_activity
ORDER BY transition_count DESC;


-- NULL Transition Validation
SELECT
    COUNTIF(patient_id IS NULL) AS null_patient_id,
    COUNTIF(activity IS NULL) AS null_activity,
    COUNTIF(next_activity IS NULL) AS null_next_activity
FROM `careflow-process-mining.careflow_staging.int_activity_transitions`;


-- Invalid Self-Transition Check
SELECT
    activity,
    next_activity,
    COUNT(*) AS transition_count
FROM `careflow-process-mining.careflow_staging.int_activity_transitions`
WHERE activity = next_activity
GROUP BY activity, next_activity;


-- Top Transitions
SELECT
    activity,
    next_activity,
    COUNT(*) AS transition_count
FROM `careflow-process-mining.careflow_staging.int_activity_transitions`
GROUP BY activity, next_activity
ORDER BY transition_count DESC
LIMIT 20;