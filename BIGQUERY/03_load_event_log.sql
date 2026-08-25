-- Verify the number of rows
SELECT *
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`
LIMIT 10;

-- Check the actual data
SELECT COUNT(*) AS total_records
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`;

-- Check that timestamps loaded correctly
SELECT
  MIN(Timestamp) AS first_event,
  MAX(Timestamp) AS last_event
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`;

-- Check that the table isn't empty
SELECT
  COUNT(*) AS total_records,
  COUNT(DISTINCT Case_ID) AS total_cases,
  COUNT(DISTINCT Patient_ID) AS total_patients
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`;


