-- ============================================================
-- CAREFLOW PROCESS MINING
-- DAY 9 - DASHBOARD ANALYTICS & KPI PREPARATION
-- Project: careflow-process-mining
-- ============================================================


-- ============================================================
-- 1. OVERALL KPI SUMMARY
-- ============================================================

SELECT
    COUNT(DISTINCT Patient_ID) AS total_patients,
    COUNT(*) AS total_events,
    COUNT(DISTINCT Department) AS total_departments,
    COUNT(DISTINCT Activity) AS total_activities,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time,
    ROUND(AVG(service_time_minutes), 2) AS avg_service_time,
    ROUND(AVG(total_process_time), 2) AS avg_process_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`;


-- ============================================================
-- 2. TOTAL BILL / REVENUE KPI
-- ============================================================

SELECT
    COUNT(*) AS total_patients,
    ROUND(SUM(Total_Bill), 2) AS total_revenue,
    ROUND(AVG(Total_Bill), 2) AS average_patient_bill,
    ROUND(MAX(Total_Bill), 2) AS maximum_bill,
    ROUND(MIN(Total_Bill), 2) AS minimum_bill
FROM `careflow-process-mining.careflow_staging.dim_patients`;


-- ============================================================
-- 3. DEPARTMENT PERFORMANCE
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


-- ============================================================
-- 4. ACTIVITY PERFORMANCE
-- ============================================================

SELECT
    Activity,
    COUNT(*) AS total_events,
    COUNT(DISTINCT Patient_ID) AS patients,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time,
    ROUND(AVG(service_time_minutes), 2) AS avg_service_time,
    ROUND(AVG(total_process_time), 2) AS avg_process_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Activity
ORDER BY total_events DESC;


-- ============================================================
-- 5. WAITING TIME ANALYSIS
-- ============================================================

SELECT
    wait_category,
    COUNT(*) AS total_events,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time,
    ROUND(MAX(wait_time_minutes), 2) AS max_wait_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY wait_category
ORDER BY avg_wait_time DESC;


-- ============================================================
-- 6. PATIENT PERFORMANCE
-- ============================================================

SELECT
    Patient_ID,
    Patient_Name,
    Disease,
    Age,
    Total_Events,
    Departments_Visited,
    Avg_Wait_Time,
    Avg_Service_Time,
    Total_Bill,
    Outcome
FROM `careflow-process-mining.careflow_staging.dim_patients`
ORDER BY Total_Bill DESC;


-- ============================================================
-- 7. OUTCOME ANALYSIS
-- ============================================================

SELECT
    Outcome,
    COUNT(*) AS patients,
    ROUND(AVG(Total_Bill), 2) AS avg_bill,
    ROUND(AVG(Avg_Wait_Time), 2) AS avg_wait_time,
    ROUND(AVG(Total_Events), 2) AS avg_events
FROM `careflow-process-mining.careflow_staging.dim_patients`
GROUP BY Outcome
ORDER BY patients DESC;


-- ============================================================
-- 8. DISEASE ANALYSIS
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


-- ============================================================
-- 9. SHIFT PERFORMANCE
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


-- ============================================================
-- 10. REWORK ANALYSIS
-- ============================================================

SELECT
    Rework_Flag,
    COUNT(*) AS total_events,
    ROUND(
        SAFE_DIVIDE(
            COUNT(*) * 100,
            SUM(COUNT(*)) OVER ()
        ), 2
    ) AS percentage
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Rework_Flag
ORDER BY total_events DESC;


-- ============================================================
-- 11. PROCESS BOTTLENECK ANALYSIS
-- ============================================================

SELECT
    Department,
    Activity,
    COUNT(*) AS event_count,
    COUNT(DISTINCT Patient_ID) AS patients,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time,
    ROUND(AVG(total_process_time), 2) AS avg_process_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Department, Activity
HAVING COUNT(*) >= 10
ORDER BY avg_wait_time DESC
LIMIT 20;


-- ============================================================
-- 12. TOP PATIENTS BY BILL
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
ORDER BY Total_Bill DESC
LIMIT 20;


-- ============================================================
-- 13. TOP PATIENTS BY WAITING TIME
-- ============================================================

SELECT
    Patient_ID,
    Patient_Name,
    Disease,
    Avg_Wait_Time,
    Total_Events,
    Outcome
FROM `careflow-process-mining.careflow_staging.dim_patients`
ORDER BY Avg_Wait_Time DESC
LIMIT 20;


-- ============================================================
-- 14. DEPARTMENT EVENT SHARE
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


-- ============================================================
-- 15. OUTCOME DISTRIBUTION
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


-- ============================================================
-- 16. AGE GROUP ANALYSIS
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


-- ============================================================
-- 17. DAILY EVENT VOLUME
-- ============================================================

SELECT
    DATE(event_timestamp) AS event_date,
    COUNT(*) AS total_events,
    COUNT(DISTINCT Patient_ID) AS patients,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY event_date
ORDER BY event_date;


-- ============================================================
-- 18. HOURLY EVENT VOLUME
-- ============================================================

SELECT
    EXTRACT(HOUR FROM event_timestamp) AS event_hour,
    COUNT(*) AS total_events,
    COUNT(DISTINCT Patient_ID) AS patients,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY event_hour
ORDER BY event_hour;


-- ============================================================
-- 19. ACTIVITY RANKING
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


-- ============================================================
-- 20. DEPARTMENT WAITING TIME RANKING
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


-- ============================================================
-- 21. HIGH WAITING TIME EVENTS
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


-- ============================================================
-- 22. REWORK RATE
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


-- ============================================================
-- 23. PROCESS TIME SUMMARY
-- ============================================================

SELECT
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time,
    ROUND(AVG(service_time_minutes), 2) AS avg_service_time,
    ROUND(AVG(total_process_time), 2) AS avg_process_time,
    ROUND(MAX(total_process_time), 2) AS max_process_time,
    ROUND(MIN(total_process_time), 2) AS min_process_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`;


-- ============================================================
-- 24. FINAL DASHBOARD KPI VIEW
-- ============================================================

CREATE OR REPLACE VIEW
`careflow-process-mining.careflow_staging.vw_dashboard_kpis`
AS
SELECT
    COUNT(DISTINCT Patient_ID) AS total_patients,
    COUNT(*) AS total_events,
    COUNT(DISTINCT Department) AS total_departments,
    COUNT(DISTINCT Activity) AS total_activities,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time,
    ROUND(AVG(service_time_minutes), 2) AS avg_service_time,
    ROUND(AVG(total_process_time), 2) AS avg_process_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`;


-- ============================================================
-- 25. CHECK DASHBOARD KPI VIEW
-- ============================================================

SELECT *
FROM `careflow-process-mining.careflow_staging.vw_dashboard_kpis`;


-- ============================================================
-- 26. PATIENT COUNT BY DEPARTMENT
-- ============================================================

SELECT
    Department,
    COUNT(DISTINCT Patient_ID) AS patient_count
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Department
ORDER BY patient_count DESC;


-- ============================================================
-- 27. PATIENT COUNT BY ACTIVITY
-- ============================================================

SELECT
    Activity,
    COUNT(DISTINCT Patient_ID) AS patient_count
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Activity
ORDER BY patient_count DESC;


-- ============================================================
-- 28. DEPARTMENT SERVICE TIME ANALYSIS
-- ============================================================

SELECT
    Department,
    ROUND(AVG(service_time_minutes), 2) AS avg_service_time,
    ROUND(MAX(service_time_minutes), 2) AS max_service_time,
    ROUND(MIN(service_time_minutes), 2) AS min_service_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Department
ORDER BY avg_service_time DESC;


-- ============================================================
-- 29. ACTIVITY SERVICE TIME ANALYSIS
-- ============================================================

SELECT
    Activity,
    ROUND(AVG(service_time_minutes), 2) AS avg_service_time,
    ROUND(MAX(service_time_minutes), 2) AS max_service_time,
    ROUND(MIN(service_time_minutes), 2) AS min_service_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Activity
ORDER BY avg_service_time DESC;


-- ============================================================
-- 30. DEPARTMENT PROCESS TIME
-- ============================================================

SELECT
    Department,
    ROUND(AVG(total_process_time), 2) AS avg_process_time,
    ROUND(MAX(total_process_time), 2) AS max_process_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Department
ORDER BY avg_process_time DESC;


-- ============================================================
-- 31. ACTIVITY WAITING TIME RANKING
-- ============================================================

SELECT
    Activity,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time,
    RANK() OVER (
        ORDER BY AVG(wait_time_minutes) DESC
    ) AS wait_rank
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Activity
ORDER BY wait_rank;


-- ============================================================
-- 32. HIGH WAITING TIME BY DEPARTMENT
-- ============================================================

SELECT
    Department,
    COUNT(*) AS high_wait_events,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
WHERE wait_time_minutes > 30
GROUP BY Department
ORDER BY high_wait_events DESC;


-- ============================================================
-- 33. LOW WAITING TIME EVENTS
-- ============================================================

SELECT
    Department,
    Activity,
    COUNT(*) AS events,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
WHERE wait_time_minutes <= 10
GROUP BY Department, Activity
ORDER BY avg_wait_time;


-- ============================================================
-- 34. WAITING TIME CATEGORY DISTRIBUTION
-- ============================================================

SELECT
    wait_category,
    COUNT(*) AS event_count,
    ROUND(
        SAFE_DIVIDE(
            COUNT(*) * 100,
            SUM(COUNT(*)) OVER ()
        ), 2
    ) AS percentage
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY wait_category
ORDER BY event_count DESC;


-- ============================================================
-- 35. DEPARTMENT REWORK ANALYSIS
-- ============================================================

SELECT
    Department,
    COUNT(*) AS total_events,
    COUNTIF(Rework_Flag = TRUE) AS rework_events,
    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Rework_Flag = TRUE) * 100,
            COUNT(*)
        ), 2
    ) AS rework_rate
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Department
ORDER BY rework_rate DESC;


-- ============================================================
-- 36. ACTIVITY REWORK ANALYSIS
-- ============================================================

SELECT
    Activity,
    COUNT(*) AS total_events,
    COUNTIF(Rework_Flag = TRUE) AS rework_events,
    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Rework_Flag = TRUE) * 100,
            COUNT(*)
        ), 2
    ) AS rework_rate
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Activity
ORDER BY rework_rate DESC;


-- ============================================================
-- 37. SHIFT REWORK ANALYSIS
-- ============================================================

SELECT
    Shift,
    COUNT(*) AS total_events,
    COUNTIF(Rework_Flag = TRUE) AS rework_events,
    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Rework_Flag = TRUE) * 100,
            COUNT(*)
        ), 2
    ) AS rework_rate
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Shift
ORDER BY rework_rate DESC;


-- ============================================================
-- 38. OUTCOME VS WAITING TIME
-- ============================================================

SELECT
    Outcome,
    COUNT(*) AS patients,
    ROUND(AVG(Avg_Wait_Time), 2) AS avg_wait_time,
    ROUND(AVG(Total_Bill), 2) AS avg_bill
FROM `careflow-process-mining.careflow_staging.dim_patients`
GROUP BY Outcome
ORDER BY avg_wait_time DESC;


-- ============================================================
-- 39. OUTCOME VS PROCESS EVENTS
-- ============================================================

SELECT
    Outcome,
    COUNT(*) AS patients,
    ROUND(AVG(Total_Events), 2) AS avg_events,
    MAX(Total_Events) AS max_events,
    MIN(Total_Events) AS min_events
FROM `careflow-process-mining.careflow_staging.dim_patients`
GROUP BY Outcome
ORDER BY avg_events DESC;


-- ============================================================
-- 40. DISEASE VS REVENUE
-- ============================================================

SELECT
    Disease,
    COUNT(*) AS patients,
    ROUND(SUM(Total_Bill), 2) AS total_revenue,
    ROUND(AVG(Total_Bill), 2) AS avg_bill
FROM `careflow-process-mining.careflow_staging.dim_patients`
GROUP BY Disease
ORDER BY total_revenue DESC;


-- ============================================================
-- 41. DISEASE VS PROCESS TIME
-- ============================================================

SELECT
    d.Disease,
    COUNT(DISTINCT d.Patient_ID) AS patients,
    ROUND(AVG(f.total_process_time), 2) AS avg_process_time
FROM `careflow-process-mining.careflow_staging.dim_patients` d
JOIN `careflow-process-mining.careflow_staging.fct_hospital_events` f
ON d.Patient_ID = f.Patient_ID
GROUP BY d.Disease
ORDER BY avg_process_time DESC;


-- ============================================================
-- 42. AGE GROUP PATIENT COUNT
-- ============================================================

SELECT
    CASE
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN Age BETWEEN 31 AND 45 THEN '31-45'
        WHEN Age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
    END AS age_group,
    COUNT(*) AS patients
FROM `careflow-process-mining.careflow_staging.dim_patients`
GROUP BY age_group
ORDER BY patients DESC;


-- ============================================================
-- 43. AGE GROUP REVENUE
-- ============================================================

SELECT
    CASE
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN Age BETWEEN 31 AND 45 THEN '31-45'
        WHEN Age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
    END AS age_group,
    ROUND(SUM(Total_Bill), 2) AS total_revenue,
    ROUND(AVG(Total_Bill), 2) AS avg_bill
FROM `careflow-process-mining.careflow_staging.dim_patients`
GROUP BY age_group
ORDER BY total_revenue DESC;


-- ============================================================
-- 44. AGE GROUP WAITING TIME
-- ============================================================

SELECT
    CASE
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN Age BETWEEN 31 AND 45 THEN '31-45'
        WHEN Age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
    END AS age_group,
    ROUND(AVG(Avg_Wait_Time), 2) AS avg_wait_time
FROM `careflow-process-mining.careflow_staging.dim_patients`
GROUP BY age_group
ORDER BY avg_wait_time DESC;


-- ============================================================
-- 45. TOP REVENUE DISEASES
-- ============================================================

SELECT
    Disease,
    ROUND(SUM(Total_Bill), 2) AS total_revenue
FROM `careflow-process-mining.careflow_staging.dim_patients`
GROUP BY Disease
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- 46. TOP DEPARTMENTS BY PATIENTS
-- ============================================================

SELECT
    Department,
    COUNT(DISTINCT Patient_ID) AS patients
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Department
ORDER BY patients DESC
LIMIT 10;


-- ============================================================
-- 47. TOP ACTIVITIES BY EVENTS
-- ============================================================

SELECT
    Activity,
    COUNT(*) AS event_count
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Activity
ORDER BY event_count DESC
LIMIT 10;


-- ============================================================
-- 48. TOP DEPARTMENTS BY WAITING TIME
-- ============================================================

SELECT
    Department,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Department
ORDER BY avg_wait_time DESC
LIMIT 10;


-- ============================================================
-- 49. TOP PATIENTS BY PROCESS TIME
-- ============================================================

SELECT
    Patient_ID,
    ROUND(SUM(total_process_time), 2) AS total_process_time,
    COUNT(*) AS total_events
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Patient_ID
ORDER BY total_process_time DESC
LIMIT 20;


-- ============================================================
-- 50. TOP PATIENTS BY NUMBER OF EVENTS
-- ============================================================

SELECT
    Patient_ID,
    COUNT(*) AS total_events
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Patient_ID
ORDER BY total_events DESC
LIMIT 20;


-- ============================================================
-- 51. PATIENT DEPARTMENT JOURNEY
-- ============================================================

SELECT
    Patient_ID,
    COUNT(DISTINCT Department) AS departments_visited,
    COUNT(*) AS total_events
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Patient_ID
ORDER BY departments_visited DESC;


-- ============================================================
-- 52. MOST VISITED DEPARTMENTS
-- ============================================================

SELECT
    Department,
    COUNT(*) AS visits
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Department
ORDER BY visits DESC;


-- ============================================================
-- 53. DEPARTMENT PATIENT SHARE
-- ============================================================

SELECT
    Department,
    COUNT(DISTINCT Patient_ID) AS patients,
    ROUND(
        SAFE_DIVIDE(
            COUNT(DISTINCT Patient_ID) * 100,
            SUM(COUNT(DISTINCT Patient_ID)) OVER ()
        ), 2
    ) AS patient_percentage
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Department
ORDER BY patient_percentage DESC;


-- ============================================================
-- 54. DAILY REVENUE
-- ============================================================

SELECT
    DATE(Admission_Date) AS admission_date,
    COUNT(*) AS patients,
    ROUND(SUM(Total_Bill), 2) AS daily_revenue,
    ROUND(AVG(Total_Bill), 2) AS avg_bill
FROM `careflow-process-mining.careflow_staging.dim_patients`
GROUP BY admission_date
ORDER BY admission_date;


-- ============================================================
-- 55. MONTHLY REVENUE
-- ============================================================

SELECT
    DATE_TRUNC(DATE(Admission_Date), MONTH) AS month,
    COUNT(*) AS patients,
    ROUND(SUM(Total_Bill), 2) AS monthly_revenue,
    ROUND(AVG(Total_Bill), 2) AS avg_bill
FROM `careflow-process-mining.careflow_staging.dim_patients`
GROUP BY month
ORDER BY month;


-- ============================================================
-- 56. DAILY PATIENT VOLUME
-- ============================================================

SELECT
    DATE(Admission_Date) AS admission_date,
    COUNT(*) AS patient_count
FROM `careflow-process-mining.careflow_staging.dim_patients`
GROUP BY admission_date
ORDER BY admission_date;


-- ============================================================
-- 57. HOURLY WAITING TIME ANALYSIS
-- ============================================================

SELECT
    EXTRACT(HOUR FROM event_timestamp) AS event_hour,
    COUNT(*) AS events,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY event_hour
ORDER BY avg_wait_time DESC;


-- ============================================================
-- 58. DOCTOR PERFORMANCE
-- ============================================================

SELECT
    Doctor_ID,
    COUNT(*) AS total_events,
    COUNT(DISTINCT Patient_ID) AS patients,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time,
    ROUND(AVG(service_time_minutes), 2) AS avg_service_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Doctor_ID
ORDER BY patients DESC;


-- ============================================================
-- 59. NURSE PERFORMANCE
-- ============================================================

SELECT
    Nurse_ID,
    COUNT(*) AS total_events,
    COUNT(DISTINCT Patient_ID) AS patients,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time,
    ROUND(AVG(service_time_minutes), 2) AS avg_service_time
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`
GROUP BY Nurse_ID
ORDER BY patients DESC;


-- ============================================================
-- 60. FINAL DASHBOARD SUMMARY
-- ============================================================

SELECT
    COUNT(DISTINCT Patient_ID) AS total_patients,
    COUNT(*) AS total_events,
    COUNT(DISTINCT Department) AS total_departments,
    COUNT(DISTINCT Activity) AS total_activities,
    ROUND(AVG(wait_time_minutes), 2) AS avg_wait_time,
    ROUND(AVG(service_time_minutes), 2) AS avg_service_time,
    ROUND(AVG(total_process_time), 2) AS avg_process_time,
    COUNTIF(Rework_Flag = TRUE) AS rework_events,
    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Rework_Flag = TRUE) * 100,
            COUNT(*)
        ), 2
    ) AS rework_rate
FROM `careflow-process-mining.careflow_staging.fct_hospital_events`;

/* git add bigquery/09_dashboard_analytics.sql
git commit -m "Day 9: Add dashboard analytics and KPI queries"
git push
*/