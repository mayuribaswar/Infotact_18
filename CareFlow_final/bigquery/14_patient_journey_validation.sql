-- ============================================================
-- CAREFLOW DAY 14
-- PATIENT JOURNEY VALIDATION
-- ============================================================


-- ============================================================
-- 1. TOTAL PATIENTS
-- ============================================================

SELECT
    COUNT(*) AS total_patients

FROM `careflow-process-mining.careflow_staging.fct_patient_journey`;


-- ============================================================
-- 2. PATIENT JOURNEY KPI SUMMARY
-- ============================================================

SELECT

    COUNT(*) AS total_patients,

    ROUND(
        AVG(total_process_time_minutes),
        2
    ) AS avg_process_time_minutes,

    MIN(total_process_time_minutes)
        AS min_process_time_minutes,

    MAX(total_process_time_minutes)
        AS max_process_time_minutes,

    APPROX_QUANTILES(
        total_process_time_minutes,
        100
    )[OFFSET(50)] AS median_process_time_minutes,

    APPROX_QUANTILES(
        total_process_time_minutes,
        100
    )[OFFSET(90)] AS p90_process_time_minutes,

    ROUND(
        AVG(total_wait_time_minutes),
        2
    ) AS avg_wait_time_minutes,

    ROUND(
        AVG(avg_wait_time_minutes),
        2
    ) AS average_patient_wait_time

FROM `careflow-process-mining.careflow_staging.fct_patient_journey`;


-- ============================================================
-- 3. TOP 20 LONGEST PATIENT JOURNEYS
-- ============================================================

SELECT

    Patient_ID,
    first_activity,
    last_activity,
    total_activities,
    total_process_time_minutes,
    total_wait_time_minutes,
    avg_wait_time_minutes,
    process_performance

FROM `careflow-process-mining.careflow_staging.fct_patient_journey`

ORDER BY total_process_time_minutes DESC

LIMIT 20;


-- ============================================================
-- 4. TOP 20 PATIENTS BY WAITING TIME
-- ============================================================

SELECT

    Patient_ID,
    first_activity,
    last_activity,
    total_process_time_minutes,
    total_wait_time_minutes,
    avg_wait_time_minutes,
    process_performance

FROM `careflow-process-mining.careflow_staging.fct_patient_journey`

ORDER BY total_wait_time_minutes DESC

LIMIT 20;


-- ============================================================
-- 5. PERFORMANCE DISTRIBUTION
-- ============================================================

SELECT

    process_performance,

    COUNT(*) AS patient_count,

    ROUND(
        AVG(total_process_time_minutes),
        2
    ) AS avg_process_time_minutes,

    ROUND(
        AVG(total_wait_time_minutes),
        2
    ) AS avg_wait_time_minutes

FROM `careflow-process-mining.careflow_staging.fct_patient_journey`

GROUP BY process_performance

ORDER BY
    CASE process_performance
        WHEN 'Fast' THEN 1
        WHEN 'Moderate' THEN 2
        WHEN 'Slow' THEN 3
    END;


-- ============================================================
-- 6. FIRST ACTIVITY DISTRIBUTION
-- ============================================================

SELECT

    first_activity,

    COUNT(*) AS patient_count,

    ROUND(
        AVG(total_process_time_minutes),
        2
    ) AS avg_process_time_minutes

FROM `careflow-process-mining.careflow_staging.fct_patient_journey`

GROUP BY first_activity

ORDER BY patient_count DESC;


-- ============================================================
-- 7. LAST ACTIVITY DISTRIBUTION
-- ============================================================

SELECT

    last_activity,

    COUNT(*) AS patient_count,

    ROUND(
        AVG(total_process_time_minutes),
        2
    ) AS avg_process_time_minutes

FROM `careflow-process-mining.careflow_staging.fct_patient_journey`

GROUP BY last_activity

ORDER BY patient_count DESC;


-- ============================================================
-- 8. DATA QUALITY CHECK
-- ============================================================

SELECT

    COUNT(*) AS total_records,

    COUNTIF(Patient_ID IS NULL)
        AS null_patient_ids,

    COUNTIF(total_process_time_minutes < 0)
        AS negative_process_times,

    COUNTIF(total_wait_time_minutes < 0)
        AS negative_wait_times,

    COUNTIF(total_activities <= 0)
        AS invalid_activity_counts

FROM `careflow-process-mining.careflow_staging.fct_patient_journey`;