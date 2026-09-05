-- =========================================================
-- CAREFLOW - DAY 19
-- VALIDATION SUMMARY
-- =========================================================

-- 1. Overall MART Summary
SELECT
    COUNT(DISTINCT patient_id) AS total_patients,
    COUNT(*) AS total_events,
    COUNT(DISTINCT activity_name) AS total_activities
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`;


-- 2. Patient Journey Summary
SELECT
    COUNT(*) AS total_journeys,
    COUNT(DISTINCT patient_id) AS unique_patients,
    AVG(total_events) AS avg_events_per_journey,
    AVG(total_wait_time_minutes) AS avg_wait_time_minutes,
    AVG(total_los_days) AS avg_los_days
FROM `careflow-process-mining.careflow_mart.fct_patient_journeys`;


-- 3. Bottleneck Summary
SELECT
    COUNT(*) AS total_bottleneck_records,
    AVG(avg_wait_time_minutes) AS overall_avg_wait_time
FROM `careflow-process-mining.careflow_mart.fct_process_bottlenecks`;


-- 4. Bottlenecks by Severity
SELECT
    severity_level,
    COUNT(*) AS bottleneck_count
FROM `careflow-process-mining.careflow_mart.fct_process_bottlenecks`
GROUP BY severity_level
ORDER BY bottleneck_count DESC;


-- 5. Department Performance
SELECT
    department,
    COUNT(*) AS event_count,
    AVG(process_duration_minutes) AS avg_process_duration
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
GROUP BY department
ORDER BY event_count DESC;