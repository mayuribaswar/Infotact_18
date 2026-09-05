{{ config(
    materialized='view'
) }}

WITH source_data AS (

    SELECT
        Event_ID,
        Patient_ID,
        Patient_Name,
        SAFE_CAST(Age AS INT64) AS Age,
        Gender,
        Disease,
        Severity,
        Patient_Type,
        Department,
        Activity,
        Activity_Status,
        SAFE_CAST(Timestamp AS TIMESTAMP) AS event_timestamp,
        SAFE_CAST(Event_Order AS INT64) AS Event_Order,
        Doctor_ID,
        Doctor_Name,
        Shift,
        SAFE_CAST(Wait_Time_Minutes AS INT64) AS wait_time_minutes,
        SAFE_CAST(Service_Time_Minutes AS INT64) AS service_time_minutes,
        SAFE_CAST(Total_Process_Time AS INT64) AS total_process_time,
        SAFE_CAST(Rework_Flag AS BOOLEAN) AS Rework_Flag,
        Previous_Activity,
        Next_Activity,
        Delay_Reason,
        Resource,
        Ward,
        Bed_Number,
        SAFE_CAST(Admission_Date AS DATE) AS Admission_Date,
        SAFE_CAST(Discharge_Date AS DATE) AS Discharge_Date,
        Outcome,
        SAFE_CAST(Total_Bill AS FLOAT64) AS Total_Bill,

        ROW_NUMBER() OVER (
            PARTITION BY Event_ID
            ORDER BY SAFE_CAST(Timestamp AS TIMESTAMP) DESC
        ) AS dedup_rank

    FROM {{ source('careflow_raw', 'hospital_event_log_raw') }}
    WHERE Event_ID IS NOT NULL
      AND Patient_ID IS NOT NULL
      AND Activity IS NOT NULL
      AND Timestamp IS NOT NULL

)

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
    Total_Bill
FROM source_data
WHERE dedup_rank = 1