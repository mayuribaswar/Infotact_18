-- ============================================================
-- CAREFLOW PROCESS MINING
-- DAY 8 - MART LAYER VALIDATION
-- Project: careflow-process-mining
-- ============================================================


-- 1. CHECK DIM_PATIENTS
-- ============================================================

SELECT *
FROM `careflow-process-mining.careflow_staging.dim_patients`
LIMIT 20;


-- 2. CHECK FCT_HOSPITAL_EVENTS
-- ============================================================

SELECT *
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
LIMIT 20;


-- 3. TOTAL PATIENTS
-- ============================================================

SELECT
    COUNT(*) AS total_patients
FROM `careflow-process-mining.careflow_staging.dim_patients`;


-- 4. UNIQUE PATIENTS IN FACT TABLE
-- ============================================================

SELECT
    COUNT(DISTINCT Patient_ID) AS unique_patients
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`;


-- 5. TOTAL EVENTS
-- ============================================================

SELECT
    COUNT(*) AS total_events
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`;


-- 6. UNIQUE EVENT IDs
-- ============================================================

SELECT
    COUNT(DISTINCT Event_ID) AS unique_events
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`;


-- 7. PATIENT SUMMARY
-- ============================================================

SELECT
    Patient_ID,
    Patient_Name,
    Disease,
    Total_Events,
    Departments_Visited,
    Avg_Wait_Time,
    Avg_Service_Time,
    Total_Bill,
    Outcome
FROM `careflow-process-mining.careflow_staging.dim_patients`
ORDER BY Total_Bill DESC
LIMIT 20;


-- 8. DEPARTMENT PERFORMANCE
-- ============================================================

SELECT
    Department,
    COUNT(*) AS total_events,
    COUNT(DISTINCT Patient_ID) AS patients,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time,
    ROUND(AVG(service_time_minutes), 2) AS avg_service_time,
    ROUND(AVG(total_process_time), 2) AS avg_process_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Department
ORDER BY avg_wait_time DESC;


-- 9. ACTIVITY PERFORMANCE
-- ============================================================

SELECT
    Activity,
    COUNT(*) AS event_count,
    COUNT(DISTINCT Patient_ID) AS patients,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time,
    ROUND(AVG(service_time_minutes), 2) AS avg_service_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Activity
ORDER BY avg_wait_time DESC;


-- 10. WAIT CATEGORY ANALYSIS
-- ============================================================

SELECT
    wait_category,
    COUNT(*) AS event_count,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY wait_category
ORDER BY event_count DESC;


-- 11. REWORK ANALYSIS
-- ============================================================

SELECT
    Rework_Flag,
    rework_status,
    COUNT(*) AS event_count
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY
    Rework_Flag,
    rework_status
ORDER BY event_count DESC;


-- 12. HIGH WAITING TIME EVENTS
-- ============================================================

SELECT
    Event_ID,
    Patient_ID,
    Activity,
    Department,
    wait_time_minutes,
    wait_category
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
WHERE wait_time_minutes > 30
ORDER BY wait_time_minutes DESC
LIMIT 100;


-- 13. TOP PATIENTS BY TOTAL BILL
-- ============================================================

SELECT
    Patient_ID,
    Patient_Name,
    Disease,
    Total_Bill,
    Outcome
FROM `careflow-process-mining.careflow_staging.dim_patients`
ORDER BY Total_Bill DESC
LIMIT 20;


-- 14. OUTCOME ANALYSIS
-- ============================================================

SELECT
    Outcome,
    COUNT(*) AS patients,
    ROUND(AVG(Total_Bill), 2) AS avg_total_bill
FROM `careflow-process-mining.careflow_staging.dim_patients`
GROUP BY Outcome
ORDER BY patients DESC;


-- 15. DISEASE ANALYSIS
-- ============================================================

SELECT
    Disease,
    COUNT(*) AS patients,
    ROUND(AVG(Age), 2) AS avg_age,
    ROUND(AVG(Avg_Wait_Time), 2) AS avg_wait_time,
    ROUND(AVG(Total_Bill), 2) AS avg_bill
FROM `careflow-process-mining.careflow_staging.dim_patients`
GROUP BY Disease
ORDER BY patients DESC;


-- 16. SHIFT PERFORMANCE
-- ============================================================

SELECT
    Shift,
    COUNT(*) AS total_events,
    COUNT(DISTINCT Patient_ID) AS patients,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time,
    ROUND(AVG(service_time_minutes), 2) AS avg_service_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Shift
ORDER BY avg_wait_time DESC;


-- 17. DOCTOR PERFORMANCE
-- ============================================================

SELECT
    Doctor_ID,
    Doctor_Name,
    COUNT(*) AS total_events,
    COUNT(DISTINCT Patient_ID) AS patients,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time,
    ROUND(AVG(service_time_minutes), 2) AS avg_service_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY
    Doctor_ID,
    Doctor_Name
ORDER BY avg_wait_time DESC;


-- 18. NULL CHECK - DIMENSION
-- ============================================================

SELECT
    COUNTIF(Patient_ID IS NULL) AS null_patient_id,
    COUNTIF(Patient_Name IS NULL) AS null_patient_name,
    COUNTIF(Disease IS NULL) AS null_disease,
    COUNTIF(Age IS NULL) AS null_age
FROM `careflow-process-mining.careflow_staging.dim_patients`;


-- 19. NULL CHECK - FACT
-- ============================================================

SELECT
    COUNTIF(Event_ID IS NULL) AS null_event_id,
    COUNTIF(Patient_ID IS NULL) AS null_patient_id,
    COUNTIF(Activity IS NULL) AS null_activity,
    COUNTIF(Department IS NULL) AS null_department,
    COUNTIF(event_timestamp IS NULL) AS null_timestamp
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`;


-- 20. PATIENT-FACT CONSISTENCY CHECK
-- ============================================================

SELECT
    COUNT(DISTINCT f.Patient_ID) AS fact_patients,
    COUNT(DISTINCT d.Patient_ID) AS dimension_patients
FROM `careflow-process-mining.careflow_staging.fct_hospital_events` f
FULL OUTER JOIN
    `careflow-process-mining.careflow_staging.dim_patients` d
ON f.Patient_ID = d.Patient_ID;


-- 21. PATIENTS WITHOUT DIMENSION RECORD
-- ============================================================

SELECT DISTINCT
    f.Patient_ID
FROM `careflow-process-mining.careflow_staging.fct_hospital_events` f
LEFT JOIN
    `careflow-process-mining.careflow_staging.dim_patients` d
ON f.Patient_ID = d.Patient_ID
WHERE d.Patient_ID IS NULL;


-- 22. ACTIVITY TRANSITIONS
-- ============================================================

SELECT
    Previous_Activity,
    Activity AS Current_Activity,
    COUNT(*) AS transition_count
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
WHERE Previous_Activity IS NOT NULL
GROUP BY
    Previous_Activity,
    Activity
ORDER BY transition_count DESC
LIMIT 100;


-- 23. PROCESS TIME ANALYSIS
-- ============================================================

SELECT
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time,
    ROUND(AVG(service_time_minutes), 2) AS avg_service_time,
    ROUND(AVG(total_process_time), 2) AS avg_total_process_time,
    MAX(total_process_time) AS max_total_process_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`;


-- 24. FINAL MART RECORD SUMMARY
-- ============================================================

SELECT
    'dim_patients' AS model_name,
    COUNT(*) AS record_count
FROM `careflow-process-mining.careflow_staging.dim_patients`

UNION ALL

SELECT
    'fct_hospital_events' AS model_name,
    COUNT(*) AS record_count
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`;

-- 25. DUPLICATE PATIENT CHECK
-- ============================================================

SELECT
    Patient_ID,
    COUNT(*) AS record_count
FROM `careflow-process-mining.careflow_staging.dim_patients`
GROUP BY Patient_ID
HAVING COUNT(*) > 1
ORDER BY record_count DESC;


-- 26. DUPLICATE EVENT CHECK
-- ============================================================

SELECT
    Event_ID,
    COUNT(*) AS record_count
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Event_ID
HAVING COUNT(*) > 1
ORDER BY record_count DESC;


-- 27. INVALID WAITING TIME CHECK
-- ============================================================

SELECT
    COUNT(*) AS invalid_wait_time_records
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
WHERE wait_time_minutes < 0;


-- 28. INVALID SERVICE TIME CHECK
-- ============================================================

SELECT
    COUNT(*) AS invalid_service_time_records
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
WHERE service_time_minutes < 0;


-- 29. INVALID PROCESS TIME CHECK
-- ============================================================

SELECT
    COUNT(*) AS invalid_process_time_records
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
WHERE total_process_time < 0;


-- 30. WAIT TIME CATEGORY CONSISTENCY
-- ============================================================

SELECT
    wait_category,
    COUNT(*) AS total_records,
    COUNTIF(wait_time_minutes < 0) AS invalid_records
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY wait_category
ORDER BY total_records DESC;


-- 31. REWORK RATE
-- ============================================================

SELECT
    COUNT(*) AS total_events,
    COUNTIF(Rework_Flag = TRUE) AS rework_events,
    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Rework_Flag = TRUE) * 100,
            COUNT(*)
        ), 2
    ) AS rework_percentage
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`;


-- 32. PATIENT EVENT DISTRIBUTION
-- ============================================================

SELECT
    Patient_ID,
    COUNT(*) AS event_count
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Patient_ID
ORDER BY event_count DESC
LIMIT 20;


-- 33. DEPARTMENT WAITING TIME RANKING
-- ============================================================

SELECT
    Department,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time,
    RANK() OVER (
        ORDER BY AVG(wait_time_minutes) DESC
    ) AS wait_time_rank
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Department
ORDER BY wait_time_rank;


-- 34. ACTIVITY FREQUENCY RANKING
-- ============================================================

SELECT
    Activity,
    COUNT(*) AS event_count,
    RANK() OVER (
        ORDER BY COUNT(*) DESC
    ) AS activity_rank
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Activity
ORDER BY activity_rank;


-- 35. OUTLIER WAITING TIME
-- ============================================================

SELECT
    Event_ID,
    Patient_ID,
    Activity,
    Department,
    wait_time_minutes
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
WHERE wait_time_minutes > (
    SELECT AVG(wait_time_minutes)
           + 3 * STDDEV(wait_time_minutes)
    FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
)
ORDER BY wait_time_minutes DESC
LIMIT 100;


-- 36. OUTLIER PROCESS TIME
-- ============================================================

SELECT
    Event_ID,
    Patient_ID,
    Activity,
    Department,
    total_process_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
WHERE total_process_time > (
    SELECT AVG(total_process_time)
           + 3 * STDDEV(total_process_time)
    FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
)
ORDER BY total_process_time DESC
LIMIT 100;


-- 37. DEPARTMENT EVENT SHARE
-- ============================================================

SELECT
    Department,
    COUNT(*) AS event_count,
    ROUND(
        SAFE_DIVIDE(
            COUNT(*) * 100,
            SUM(COUNT(*)) OVER ()
        ), 2
    ) AS event_percentage
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Department
ORDER BY event_count DESC;


-- 38. OUTCOME DISTRIBUTION
-- ============================================================

SELECT
    Outcome,
    COUNT(*) AS patient_count,
    ROUND(
        SAFE_DIVIDE(
            COUNT(*) * 100,
            SUM(COUNT(*)) OVER ()
        ), 2
    ) AS percentage
FROM `careflow-process-mining.careflow_staging.dim_patients`
GROUP BY Outcome
ORDER BY patient_count DESC;


-- 39. AGE GROUP ANALYSIS
-- ============================================================

SELECT
    CASE
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN Age BETWEEN 31 AND 45 THEN '31-45'
        WHEN Age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
    END AS age_group,
    COUNT(*) AS patients,
    ROUND(AVG(Total_Bill), 2) AS avg_bill,
    ROUND(AVG(Avg_Wait_Time), 2) AS avg_wait_time
FROM `careflow-process-mining.careflow_staging.dim_patients`
GROUP BY age_group
ORDER BY patients DESC;


-- 40. HIGH BILL PATIENT ANALYSIS
-- ============================================================

SELECT
    Patient_ID,
    Patient_Name,
    Disease,
    Total_Bill,
    Total_Events,
    Avg_Wait_Time,
    Outcome
FROM `careflow-process-mining.careflow_staging.dim_patients`
WHERE Total_Bill > (
    SELECT AVG(Total_Bill) + STDDEV(Total_Bill)
    FROM `careflow-process-mining.careflow_staging.dim_patients`
)
ORDER BY Total_Bill DESC;


-- 41. DEPARTMENT + OUTCOME ANALYSIS
-- ============================================================

SELECT
    f.Department,
    d.Outcome,
    COUNT(DISTINCT f.Patient_ID) AS patients,
    ROUND(AVG(f.wait_time_minutes), 2) AS avg_wait_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events` f
JOIN `careflow-process-mining.careflow_staging.dim_patients` d
    ON f.Patient_ID = d.Patient_ID
GROUP BY
    f.Department,
    d.Outcome
ORDER BY
    f.Department,
    patients DESC;


-- 42. DAILY EVENT VOLUME
-- ============================================================

SELECT
    DATE(event_timestamp) AS event_date,
    COUNT(*) AS total_events,
    COUNT(DISTINCT Patient_ID) AS patients,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY event_date
ORDER BY event_date;


-- 43. HOURLY EVENT VOLUME
-- ============================================================

SELECT
    EXTRACT(HOUR FROM event_timestamp) AS event_hour,
    COUNT(*) AS total_events,
    COUNT(DISTINCT Patient_ID) AS patients,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY event_hour
ORDER BY event_hour;


-- 44. FINAL DATA QUALITY SCORE
-- ============================================================

SELECT
    COUNT(*) AS total_events,
    COUNTIF(Event_ID IS NULL) AS null_event_ids,
    COUNTIF(Patient_ID IS NULL) AS null_patient_ids,
    COUNTIF(Activity IS NULL) AS null_activities,
    COUNTIF(Department IS NULL) AS null_departments,
    COUNTIF(wait_time_minutes < 0) AS negative_wait_times,
    COUNTIF(service_time_minutes < 0) AS negative_service_times,
    COUNTIF(total_process_time < 0) AS negative_process_times
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`;