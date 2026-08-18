{{ config(
    materialized='table'
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
    wait_category,
    rework_status,
    activity_priority

FROM {{ ref('int_normalized_event_log') }}