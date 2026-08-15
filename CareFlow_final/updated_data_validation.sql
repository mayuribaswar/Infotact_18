-- Row count
SELECT COUNT(*) AS total_rows
FROM `careflow.careflow_raw.hospital_event_log_cleaned`;

-- Duplicate Event IDs
SELECT Event_ID, COUNT(*) AS count
FROM `careflow.careflow_raw.hospital_event_log_cleaned`
GROUP BY Event_ID
HAVING COUNT(*) > 1;

-- Invalid age
SELECT *
FROM `careflow.careflow_raw.hospital_event_log_cleaned`
WHERE Age < 0;

-- Negative waiting/service time
SELECT *
FROM `careflow.careflow_raw.hospital_event_log_cleaned`
WHERE Wait_Time_Minutes < 0
   OR Service_Time_Minutes < 0;

-- Negative bills
SELECT *
FROM `careflow.careflow_raw.hospital_event_log_cleaned`
WHERE Total_Bill < 0;