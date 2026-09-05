{{ config(materialized='table') }}

SELECT
    n.Event_ID,
    n.Patient_ID,
    n.Patient_Name,
    n.Age,
    n.Gender,
    n.Disease,
    n.Severity,
    n.Patient_Type,
    n.Department,
    n.Activity,
    n.Activity_Status,
    n.event_timestamp,
    o.event_order,
    n.Doctor_ID,
    n.Doctor_Name,
    n.Shift,
    n.wait_time_minutes,
    n.service_time_minutes,
    n.total_process_time,
    n.Rework_Flag,
    n.Previous_Activity,
    n.Next_Activity,
    n.Delay_Reason,
    n.Resource,
    n.Ward,
    n.Bed_Number,
    n.Admission_Date,
    n.Discharge_Date,
    n.Outcome,
    n.Total_Bill,
    n.wait_category,
    n.rework_status,
    n.activity_priority

FROM {{ ref('int_normalized_event_log') }} n
INNER JOIN {{ ref('int_ordered_events') }} o
    ON n.Event_ID = o.Event_ID