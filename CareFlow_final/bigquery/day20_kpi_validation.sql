-- =========================================================
-- CAREFLOW - DAY 20
-- MEMBER 2: BIGQUERY + DBT
-- KPI AND ANALYTICS VALIDATION
-- =========================================================


-- =========================================================
-- 1. OVERALL KPI SUMMARY
-- =========================================================

SELECT
    COUNT(DISTINCT patient_id) AS total_patients,
    COUNT(*) AS total_events,
    COUNT(DISTINCT activity_name) AS total_activities,
    COUNT(DISTINCT department) AS total_departments
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`;


-- =========================================================
-- 2. PATIENT JOURNEY KPIs
-- =========================================================

SELECT
    COUNT(*) AS total_journeys,
    COUNT(DISTINCT patient_id) AS unique_patients,
    ROUND(AVG(total_events), 2) AS avg_events_per_journey,
    ROUND(AVG(total_wait_time_minutes), 2) AS avg_wait_time_minutes,
    ROUND(AVG(total_los_days), 2) AS avg_los_days
FROM `careflow-process-mining.careflow_mart.fct_patient_journeys`;


-- =========================================================
-- 3. REWORK KPI
-- =========================================================

SELECT
    COUNT(*) AS total_journeys,
    COUNTIF(had_rework = TRUE) AS journeys_with_rework,
    ROUND(
        SAFE_DIVIDE(
            COUNTIF(had_rework = TRUE),
            COUNT(*)
        ) * 100,
        2
    ) AS rework_percentage
FROM `careflow-process-mining.careflow_mart.fct_patient_journeys`;


-- =========================================================
-- 4. DEPARTMENT PERFORMANCE
-- =========================================================

SELECT
    department,
    COUNT(*) AS total_events,
    COUNT(DISTINCT patient_id) AS unique_patients,
    ROUND(AVG(process_duration_minutes), 2)
        AS avg_process_duration_minutes
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
GROUP BY department
ORDER BY total_events DESC;


-- =========================================================
-- 5. ACTIVITY PERFORMANCE
-- =========================================================

SELECT
    activity_name,
    COUNT(*) AS event_count,
    COUNT(DISTINCT patient_id) AS unique_patients,
    ROUND(AVG(process_duration_minutes), 2)
        AS avg_process_duration_minutes
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
GROUP BY activity_name
ORDER BY event_count DESC;


-- =========================================================
-- 6. BOTTLENECK KPI
-- =========================================================

SELECT
    department,
    severity_level,
    COUNT(*) AS bottleneck_count,
    ROUND(AVG(avg_wait_time_minutes), 2)
        AS avg_wait_time_minutes
FROM `careflow-process-mining.careflow_mart.fct_process_bottlenecks`
GROUP BY department, severity_level
ORDER BY avg_wait_time_minutes DESC;


-- =========================================================
-- 7. CRITICAL BOTTLENECKS
-- =========================================================

SELECT
    department,
    avg_wait_time_minutes,
    bottleneck_rank,
    severity_level
FROM `careflow-process-mining.careflow_mart.fct_process_bottlenecks`
WHERE severity_level = 'Critical'
ORDER BY avg_wait_time_minutes DESC;


-- =========================================================
-- 8. LENGTH OF STAY ANALYSIS
-- =========================================================

SELECT
    ROUND(MIN(total_los_days), 2) AS min_los_days,
    ROUND(AVG(total_los_days), 2) AS avg_los_days,
    ROUND(MAX(total_los_days), 2) AS max_los_days
FROM `careflow-process-mining.careflow_mart.fct_patient_journeys`;


-- =========================================================
-- 9. TOP PATIENTS BY WAITING TIME
-- =========================================================

SELECT
    patient_id,
    case_id,
    total_wait_time_minutes,
    total_los_days,
    total_events
FROM `careflow-process-mining.careflow_mart.fct_patient_journeys`
ORDER BY total_wait_time_minutes DESC
LIMIT 20;


-- =========================================================
-- 10. SLOWEST ACTIVITIES
-- =========================================================

SELECT
    activity_name,
    COUNT(*) AS event_count,
    ROUND(AVG(process_duration_minutes), 2)
        AS avg_duration_minutes,
    ROUND(MAX(process_duration_minutes), 2)
        AS max_duration_minutes
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
GROUP BY activity_name
ORDER BY avg_duration_minutes DESC
LIMIT 20;


-- =========================================================
-- 11. KPI DATA QUALITY CHECK
-- =========================================================

SELECT
    COUNTIF(process_duration_minutes < 0)
        AS negative_duration_records,

    COUNTIF(process_duration_minutes IS NULL)
        AS null_duration_records,

    COUNTIF(patient_id IS NULL)
        AS null_patient_records,

    COUNTIF(activity_name IS NULL)
        AS null_activity_records
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`;


-- =========================================================
-- 12. FINAL KPI SUMMARY
-- =========================================================

SELECT
    'Total Patients' AS kpi,
    CAST(COUNT(DISTINCT patient_id) AS STRING) AS value
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`

UNION ALL

SELECT
    'Total Events',
    CAST(COUNT(*) AS STRING)
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`

UNION ALL

SELECT
    'Total Activities',
    CAST(COUNT(DISTINCT activity_name) AS STRING)
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`

UNION ALL

SELECT
    'Total Departments',
    CAST(COUNT(DISTINCT department) AS STRING)
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`;