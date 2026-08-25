-- Create a hospital_event table
CREATE TABLE `careflow-process-mining.careflow_raw.hospital_event_log_raw` (
  Event_ID STRING,
  Case_ID STRING,
  Patient_ID STRING,
  Visit_Type STRING,
  Activity STRING,
  Department STRING,
  Timestamp TIMESTAMP,
  Doctor_ID STRING,
  Severity STRING,
  Waiting_Time_Minutes INT64,
  Cost FLOAT64,
  Status STRING
);

-- Verification of the table 
SELECT
  column_name,
  data_type,
  ordinal_position
FROM `careflow-process-mining.careflow_raw.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'hospital_event'
ORDER BY ordinal_position;
