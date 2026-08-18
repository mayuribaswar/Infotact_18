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
    TIMESTAMP(Timestamp) AS event_timestamp,
    Event_Order,
    Doctor_ID,
    Doctor_Name,
    Shift,
    CAST(Wait_Time_Minutes AS INT64) AS wait_time_minutes,
    CAST(Service_Time_Minutes AS INT64) AS service_time_minutes,
    CAST(Total_Process_Time AS INT64) AS total_process_time,
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
    Total_Bill
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`
WHERE Event_ID IS NOT NULL
  AND Patient_ID IS NOT NULL
  AND Activity IS NOT NULL
  AND Timestamp IS NOT NULL