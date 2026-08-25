-- ============================================================
-- CAREFLOW PROCESS MINING
-- PRE-DATA-CLEANING VALIDATION & EXPLORATION
-- Raw Table: hospital_event_log_raw
-- ============================================================


-- ============================================================
-- 1. CHECK TABLE EXISTS
-- ============================================================

SELECT
  table_name
FROM `careflow-process-mining.careflow_raw.INFORMATION_SCHEMA.TABLES`
WHERE table_name = 'hospital_event_log_raw';


-- ============================================================
-- 2. CHECK TABLE SCHEMA
-- ============================================================

SELECT
  ordinal_position,
  column_name,
  data_type,
  is_nullable
FROM `careflow-process-mining.careflow_raw.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'hospital_event_log_raw'
ORDER BY ordinal_position;


-- ============================================================
-- 3. CHECK TOTAL RECORDS
-- ============================================================

SELECT
  COUNT(*) AS total_records
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`;


-- ============================================================
-- 4. DISPLAY SAMPLE DATA
-- ============================================================

SELECT *
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`
LIMIT 20;


-- ============================================================
-- 5. CHECK UNIQUE PATIENTS
-- ============================================================

SELECT
  COUNT(DISTINCT Patient_ID) AS total_patients
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`;


-- ============================================================
-- 6. CHECK UNIQUE CASES
-- ============================================================

SELECT
  COUNT(DISTINCT Case_ID) AS total_cases
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`;


-- ============================================================
-- 7. CHECK UNIQUE EVENTS
-- ============================================================

SELECT
  COUNT(DISTINCT Event_ID) AS total_unique_events
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`;


-- ============================================================
-- 8. CHECK NULL VALUES
-- ============================================================

SELECT
  COUNTIF(Event_ID IS NULL) AS null_event_id,
  COUNTIF(Case_ID IS NULL) AS null_case_id,
  COUNTIF(Patient_ID IS NULL) AS null_patient_id,
  COUNTIF(Activity IS NULL) AS null_activity,
  COUNTIF(Timestamp IS NULL) AS null_timestamp,
  COUNTIF(Status IS NULL) AS null_status
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`;


-- ============================================================
-- 9. CHECK DUPLICATE EVENT IDs
-- ============================================================

SELECT
  Event_ID,
  COUNT(*) AS occurrence_count
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`
WHERE Event_ID IS NOT NULL
GROUP BY Event_ID
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;


-- ============================================================
-- 10. COUNT TOTAL DUPLICATE RECORDS
-- ============================================================

SELECT
  COUNT(*) AS duplicate_records
FROM (
  SELECT
    Event_ID
  FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`
  WHERE Event_ID IS NOT NULL
  GROUP BY Event_ID
  HAVING COUNT(*) > 1
);


-- ============================================================
-- 11. CHECK DUPLICATE CASE + ACTIVITY + TIMESTAMP
-- ============================================================

SELECT
  Case_ID,
  Activity,
  Timestamp,
  COUNT(*) AS occurrences
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`
GROUP BY
  Case_ID,
  Activity,
  Timestamp
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;


-- ============================================================
-- 12. ACTIVITY DISTRIBUTION
-- ============================================================

SELECT
  Activity,
  COUNT(*) AS total_events
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`
GROUP BY Activity
ORDER BY total_events DESC;


-- ============================================================
-- 13. STATUS DISTRIBUTION
-- ============================================================

SELECT
  Status,
  COUNT(*) AS total_records
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`
GROUP BY Status
ORDER BY total_records DESC;


-- ============================================================
-- 14. CHECK BLANK / EMPTY VALUES
-- ============================================================

SELECT
  COUNTIF(TRIM(CAST(Event_ID AS STRING)) = '') AS blank_event_id,
  COUNTIF(TRIM(CAST(Case_ID AS STRING)) = '') AS blank_case_id,
  COUNTIF(TRIM(CAST(Patient_ID AS STRING)) = '') AS blank_patient_id,
  COUNTIF(TRIM(Activity) = '') AS blank_activity,
  COUNTIF(TRIM(Status) = '') AS blank_status
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`;


-- ============================================================
-- 15. CHECK TIMESTAMP RANGE
-- ============================================================

SELECT
  MIN(Timestamp) AS earliest_timestamp,
  MAX(Timestamp) AS latest_timestamp
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`;


-- ============================================================
-- 16. CHECK INVALID / FUTURE TIMESTAMPS
-- ============================================================

SELECT
  COUNT(*) AS invalid_timestamp_records
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`
WHERE Timestamp IS NULL;


-- ============================================================
-- 17. CHECK EVENTS PER CASE
-- ============================================================

SELECT
  Case_ID,
  COUNT(*) AS event_count
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`
WHERE Case_ID IS NOT NULL
GROUP BY Case_ID
ORDER BY event_count DESC;


-- ============================================================
-- 18. CHECK CASES WITH ONLY ONE EVENT
-- ============================================================

SELECT
  COUNT(*) AS single_event_cases
FROM (
  SELECT
    Case_ID
  FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`
  WHERE Case_ID IS NOT NULL
  GROUP BY Case_ID
  HAVING COUNT(*) = 1
);


-- ============================================================
-- 19. CHECK LOOP-BACK ACTIVITIES
-- ============================================================

SELECT
  Case_ID,
  Activity,
  COUNT(*) AS activity_count
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`
WHERE Case_ID IS NOT NULL
  AND Activity IS NOT NULL
GROUP BY
  Case_ID,
  Activity
HAVING COUNT(*) > 1
ORDER BY
  Case_ID,
  activity_count DESC;


-- ============================================================
-- 20. CHECK ACTIVITY SEQUENCE
-- ============================================================

SELECT
  Case_ID,
  Patient_ID,
  Activity,
  Timestamp,
  LAG(Activity) OVER (
    PARTITION BY Case_ID
    ORDER BY Timestamp
  ) AS previous_activity
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`
ORDER BY Case_ID, Timestamp;


-- ============================================================
-- 21. CHECK REPEATED CONSECUTIVE ACTIVITIES
-- ============================================================

WITH activity_sequence AS (
  SELECT
    Case_ID,
    Activity,
    Timestamp,
    LAG(Activity) OVER (
      PARTITION BY Case_ID
      ORDER BY Timestamp
    ) AS previous_activity
  FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`
)

SELECT
  Case_ID,
  Activity,
  Timestamp
FROM activity_sequence
WHERE Activity = previous_activity
ORDER BY Case_ID, Timestamp;


-- ============================================================
-- 22. CHECK CASE START AND END TIME
-- ============================================================

SELECT
  Case_ID,
  MIN(Timestamp) AS case_start_time,
  MAX(Timestamp) AS case_end_time,
  TIMESTAMP_DIFF(
    MAX(Timestamp),
    MIN(Timestamp),
    MINUTE
  ) AS case_duration_minutes
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`
WHERE Case_ID IS NOT NULL
GROUP BY Case_ID
ORDER BY case_duration_minutes DESC;


-- ============================================================
-- 23. CHECK NEGATIVE / INVALID CASE DURATIONS
-- ============================================================

SELECT
  Case_ID,
  MIN(Timestamp) AS start_time,
  MAX(Timestamp) AS end_time
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`
WHERE Case_ID IS NOT NULL
GROUP BY Case_ID
HAVING MAX(Timestamp) < MIN(Timestamp);


-- ============================================================
-- 24. CHECK EVENTS PER PATIENT
-- ============================================================

SELECT
  Patient_ID,
  COUNT(*) AS total_events,
  COUNT(DISTINCT Case_ID) AS total_cases
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`
WHERE Patient_ID IS NOT NULL
GROUP BY Patient_ID
ORDER BY total_events DESC;


-- ============================================================
-- 25. CHECK ACTIVITY FREQUENCY
-- ============================================================

SELECT
  Activity,
  COUNT(*) AS event_count,
  COUNT(DISTINCT Case_ID) AS cases_involved,
  COUNT(DISTINCT Patient_ID) AS patients_involved
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`
WHERE Activity IS NOT NULL
GROUP BY Activity
ORDER BY event_count DESC;


-- ============================================================
-- 26. CHECK STATUS BY ACTIVITY
-- ============================================================

SELECT
  Activity,
  Status,
  COUNT(*) AS total_events
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`
WHERE Activity IS NOT NULL
GROUP BY
  Activity,
  Status
ORDER BY Activity, total_events DESC;


-- ============================================================
-- 27. CHECK PATIENT STATUS
-- ============================================================

SELECT
  Status,
  COUNT(DISTINCT Patient_ID) AS patients
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`
WHERE Status IS NOT NULL
GROUP BY Status
ORDER BY patients DESC;


-- ============================================================
-- 28. CHECK CASE STATUS
-- ============================================================

SELECT
  Status,
  COUNT(DISTINCT Case_ID) AS cases
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`
WHERE Status IS NOT NULL
GROUP BY Status
ORDER BY cases DESC;


-- ============================================================
-- 29. CHECK ACTIVITY ORDER FOR EACH CASE
-- ============================================================

SELECT
  Case_ID,
  ARRAY_AGG(
    Activity
    ORDER BY Timestamp
  ) AS activity_sequence
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`
WHERE Case_ID IS NOT NULL
GROUP BY Case_ID
LIMIT 20;


-- ============================================================
-- 30. BASIC DATA QUALITY SUMMARY
-- ============================================================

SELECT
  COUNT(*) AS total_records,

  COUNT(DISTINCT Event_ID) AS unique_events,

  COUNT(DISTINCT Case_ID) AS unique_cases,

  COUNT(DISTINCT Patient_ID) AS unique_patients,

  COUNTIF(Event_ID IS NULL) AS null_event_id,

  COUNTIF(Case_ID IS NULL) AS null_case_id,

  COUNTIF(Patient_ID IS NULL) AS null_patient_id,

  COUNTIF(Activity IS NULL) AS null_activity,

  COUNTIF(Timestamp IS NULL) AS null_timestamp,

  COUNTIF(Status IS NULL) AS null_status

FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`;
