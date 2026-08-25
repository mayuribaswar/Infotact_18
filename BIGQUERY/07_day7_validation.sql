-- ============================================================
-- CAREFLOW PROCESS MINING - DAY 7
-- STAGING + INTERMEDIATE VALIDATION
-- Project: careflow-process-mining
-- ============================================================


-- 1. Check staging model
SELECT *
FROM `careflow-process-mining.careflow_staging.stg_hospital_event_log`
LIMIT 20;


-- 2. Check intermediate model
SELECT *
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`
LIMIT 20;


-- 3. Total events in staging
SELECT
    COUNT(*) AS total_events
FROM `careflow-process-mining.careflow_staging.stg_hospital_event_log`;


-- 4. Total events in intermediate
SELECT
    COUNT(*) AS total_events
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`;


-- 5. Unique patients
SELECT
    COUNT(DISTINCT Patient_ID) AS unique_patients
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`;


-- 6. Unique events
SELECT
    COUNT(DISTINCT Event_ID) AS unique_events
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`;


-- 7. Activity-wise event count
SELECT
    Activity,
    COUNT(*) AS event_count
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`
GROUP BY Activity
ORDER BY event_count DESC;


-- 8. Department-wise event count
SELECT
    Department,
    COUNT(*) AS event_count,
    COUNT(DISTINCT Patient_ID) AS patients
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`
GROUP BY Department
ORDER BY event_count DESC;


-- 9. Wait category analysis
SELECT
    wait_category,
    COUNT(*) AS event_count
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`
GROUP BY wait_category
ORDER BY event_count DESC;


-- 10. Rework analysis
SELECT
    Rework_Flag,
    rework_status,
    COUNT(*) AS event_count
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`
GROUP BY
    Rework_Flag,
    rework_status
ORDER BY event_count DESC;


-- 11. Average waiting time by department
SELECT
    Department,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_minutes,
    MAX(wait_time_minutes) AS max_wait_minutes
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`
GROUP BY Department
ORDER BY avg_wait_minutes DESC;


-- 12. High waiting-time events
SELECT
    Event_ID,
    Patient_ID,
    Activity,
    Department,
    wait_time_minutes,
    wait_category
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`
WHERE wait_time_minutes > 30
ORDER BY wait_time_minutes DESC
LIMIT 100;


-- 13. Patient process sequence
SELECT
    Patient_ID,
    Event_Order,
    Activity,
    Department,
    event_timestamp,
    Previous_Activity,
    Next_Activity
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`
ORDER BY
    Patient_ID,
    Event_Order
LIMIT 200;


-- 14. Activity transitions
SELECT
    Previous_Activity,
    Activity AS Current_Activity,
    COUNT(*) AS transition_count
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`
WHERE Previous_Activity IS NOT NULL
GROUP BY
    Previous_Activity,
    Activity
ORDER BY transition_count DESC
LIMIT 100;


-- 15. Check NULL values
SELECT
    COUNTIF(Event_ID IS NULL) AS null_event_id,
    COUNTIF(Patient_ID IS NULL) AS null_patient_id,
    COUNTIF(Activity IS NULL) AS null_activity,
    COUNTIF(event_timestamp IS NULL) AS null_timestamp,
    COUNTIF(Department IS NULL) AS null_department,
    COUNTIF(Rework_Flag IS NULL) AS null_rework_flag
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`;


-- 16. Check derived fields
SELECT
    wait_category,
    rework_status,
    activity_priority,
    COUNT(*) AS records
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`
GROUP BY
    wait_category,
    rework_status,
    activity_priority
ORDER BY records DESC;