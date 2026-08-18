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