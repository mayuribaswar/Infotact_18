{{ config(materialized='table') }}

WITH ranked_events AS (

    SELECT
        Patient_ID,
        Patient_Name,
        Age,
        Gender,
        Disease,
        Patient_Type,
        Admission_Date,
        Discharge_Date,
        Outcome,
        wait_time_minutes,
        service_time_minutes,
        Total_Bill,
        ROW_NUMBER() OVER (
            PARTITION BY Patient_ID 
            ORDER BY event_timestamp DESC, Event_ID DESC
        ) AS recency_rank
    FROM {{ ref('int_normalized_event_log') }}

),

patient_aggregates AS (

    SELECT
        Patient_ID,
        COUNT(DISTINCT Event_ID) AS Total_Events,
        COUNT(DISTINCT Department) AS Departments_Visited,
        ROUND(AVG(wait_time_minutes), 2) AS Avg_Wait_Time,
        ROUND(AVG(service_time_minutes), 2) AS Avg_Service_Time,
        ROUND(SUM(COALESCE(Total_Bill, 0)), 2) AS Total_Bill
    FROM {{ ref('int_normalized_event_log') }}
    GROUP BY Patient_ID

)

SELECT
    r.Patient_ID,
    r.Patient_Name,
    r.Age,
    r.Gender,
    r.Disease,
    r.Patient_Type,
    r.Admission_Date,
    r.Discharge_Date,
    r.Outcome,
    a.Total_Events,
    a.Departments_Visited,
    a.Avg_Wait_Time,
    a.Avg_Service_Time,
    a.Total_Bill

FROM ranked_events r
INNER JOIN patient_aggregates a
    ON r.Patient_ID = a.Patient_ID
WHERE r.recency_rank = 1