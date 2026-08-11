CREATE TABLE `careflow-process-mining.careflow_raw.hospital_event`
(
  Case_ID STRING,
  Patient_ID STRING,
  Activity STRING,
  Department STRING,
  Timestamp TIMESTAMP,
  Doctor_ID STRING,
  Nurse_ID STRING,
  Severity STRING,
  Waiting_Time_Minutes INT64,
  Status STRING
);
