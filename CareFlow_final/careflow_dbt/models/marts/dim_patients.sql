{{ config(
    materialized='table'
) }}

SELECT
    Patient_ID,
    ANY_VALUE(Patient_Name) AS Patient_Name,
    ANY_VALUE(Age) AS Age,
    ANY_VALUE(Gender) AS Gender,
    ANY_VALUE(Disease) AS Disease,
    ANY_VALUE(Patient_Type) AS Patient_Type,
    MIN(Admission_Date) AS Admission_Date,
    MAX(Discharge_Date) AS Discharge_Date,
    ANY_VALUE(Outcome) AS Outcome,
    COUNT(DISTINCT Event_ID) AS Total_Events,
    COUNT(DISTINCT Department) AS Departments_Visited,
    ROUND(AVG(wait_time_minutes), 2) AS Avg_Wait_Time,
    ROUND(AVG(service_time_minutes), 2) AS Avg_Service_Time,
    ROUND(SUM(Total_Bill), 2) AS Total_Bill

FROM {{ ref('int_normalized_event_log') }}

GROUP BY Patient_ID