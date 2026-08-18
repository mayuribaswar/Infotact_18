{{ config(
    materialized='view'
) }}

SELECT
    Event_ID,
    Patient_ID,
    Patient_Name,
    Age,
    Gender,
    Disease,
    Severity,
    Patient_Type,
    Department,
    Activity,
    Activity_Status,
    event_timestamp,
    Event_Order,
    Doctor_ID,
    Doctor_Name,
    Shift,
    wait_time_minutes,
    service_time_minutes,
    total_process_time,
    Rework_Flag,
    Previous_Activity,
    Next_Activity,
    Delay_Reason,
    Resource,
    Ward,
    Bed_Number,
    Admission_Date,
    Discharge_Date,
    Outcome,
    Total_Bill,

    -- Derived fields
    CASE
        WHEN wait_time_minutes > 30 THEN 'High Wait'
        WHEN wait_time_minutes > 15 THEN 'Medium Wait'
        ELSE 'Low Wait'
    END AS wait_category,

    CASE
        WHEN Rework_Flag = TRUE THEN 'Rework'
        ELSE 'No Rework'
    END AS rework_status,

    CASE
        WHEN Activity = 'Admission' THEN 1
        WHEN Activity = 'Discharge' THEN 2
        ELSE 3
    END AS activity_priority

FROM {{ ref('stg_hospital_event_log') }}