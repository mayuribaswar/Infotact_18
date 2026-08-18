-- ============================================================
-- CAREFLOW PROCESS MINING - MEMBER 4 - DAY 7
-- VALIDATE DBT OUTPUT
-- Project: careflow-process-mining
-- Purpose: Validate staging and normalized dbt models before PM4Py
-- GitHub commit: test: validate dbt output
-- ============================================================


-- ============================================================
-- 1. PREVIEW DBT OUTPUT
-- ============================================================

-- Staging model
SELECT *
FROM `careflow-process-mining.careflow_staging.stg_hospital_event_log`
LIMIT 20;

-- Normalized/intermediate model
SELECT *
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`
LIMIT 20;


-- ============================================================
-- 2. RECORD COUNT VALIDATION
-- Expected: staging and normalized models should contain
-- the same number of event records unless the dbt model
-- intentionally filters or expands records.
-- ============================================================

WITH counts AS (
  SELECT
    (SELECT COUNT(*)
     FROM `careflow-process-mining.careflow_staging.stg_hospital_event_log`) AS staging_count,
    (SELECT COUNT(*)
     FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`) AS normalized_count
)
SELECT
  staging_count,
  normalized_count,
  normalized_count - staging_count AS count_difference,
  CASE
    WHEN staging_count = normalized_count THEN 'PASS'
    ELSE 'CHECK'
  END AS validation_status
FROM counts;


-- ============================================================
-- 3. UNIQUE EVENT ID VALIDATION
-- Expected: every Event_ID should identify one event.
-- ============================================================

SELECT
  COUNT(*) AS total_records,
  COUNT(DISTINCT Event_ID) AS unique_event_ids,
  COUNTIF(Event_ID IS NULL) AS null_event_ids,
  CASE
    WHEN COUNT(*) = COUNT(DISTINCT Event_ID)
         AND COUNTIF(Event_ID IS NULL) = 0
    THEN 'PASS'
    ELSE 'FAIL'
  END AS validation_status
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`;


-- Duplicate Event_ID details
SELECT
  Event_ID,
  COUNT(*) AS duplicate_count
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`
GROUP BY Event_ID
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- ============================================================
-- 4. REQUIRED FIELD / NULL VALIDATION
-- ============================================================

SELECT
  COUNTIF(Event_ID IS NULL) AS null_event_id,
  COUNTIF(Patient_ID IS NULL) AS null_patient_id,
  COUNTIF(Activity IS NULL) AS null_activity,
  COUNTIF(event_timestamp IS NULL) AS null_timestamp,
  COUNTIF(Department IS NULL) AS null_department,
  COUNTIF(Rework_Flag IS NULL) AS null_rework_flag,
  CASE
    WHEN COUNTIF(Event_ID IS NULL)
       + COUNTIF(Patient_ID IS NULL)
       + COUNTIF(Activity IS NULL)
       + COUNTIF(event_timestamp IS NULL)
       + COUNTIF(Department IS NULL)
       + COUNTIF(Rework_Flag IS NULL) = 0
    THEN 'PASS'
    ELSE 'FAIL'
  END AS validation_status
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`;


-- ============================================================
-- 5. UNIQUE PATIENT VALIDATION
-- ============================================================

SELECT
  COUNT(DISTINCT Patient_ID) AS unique_patients,
  COUNTIF(Patient_ID IS NULL) AS null_patient_ids,
  CASE
    WHEN COUNT(DISTINCT Patient_ID) > 0
         AND COUNTIF(Patient_ID IS NULL) = 0
    THEN 'PASS'
    ELSE 'FAIL'
  END AS validation_status
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`;


-- ============================================================
-- 6. EVENT ORDER VALIDATION
-- Check whether each patient's event order is increasing.
-- ============================================================

WITH ordered_events AS (
  SELECT
    Patient_ID,
    Event_Order,
    LAG(Event_Order) OVER (
      PARTITION BY Patient_ID
      ORDER BY Event_Order
    ) AS previous_event_order
  FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`
)
SELECT
  COUNTIF(previous_event_order IS NOT NULL
          AND Event_Order <= previous_event_order) AS invalid_event_order_rows,
  CASE
    WHEN COUNTIF(previous_event_order IS NOT NULL
                 AND Event_Order <= previous_event_order) = 0
    THEN 'PASS'
    ELSE 'FAIL'
  END AS validation_status
FROM ordered_events;


-- ============================================================
-- 7. TIMESTAMP ORDER VALIDATION
-- Check whether timestamps are non-decreasing per patient.
-- ============================================================

WITH ordered_events AS (
  SELECT
    Patient_ID,
    event_timestamp,
    LAG(event_timestamp) OVER (
      PARTITION BY Patient_ID
      ORDER BY Event_Order
    ) AS previous_timestamp
  FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`
)
SELECT
  COUNTIF(previous_timestamp IS NOT NULL
          AND event_timestamp < previous_timestamp) AS invalid_timestamp_rows,
  CASE
    WHEN COUNTIF(previous_timestamp IS NOT NULL
                 AND event_timestamp < previous_timestamp) = 0
    THEN 'PASS'
    ELSE 'FAIL'
  END AS validation_status
FROM ordered_events;


-- ============================================================
-- 8. PREVIOUS / NEXT ACTIVITY VALIDATION
-- ============================================================

WITH ordered_events AS (
  SELECT
    Patient_ID,
    Event_Order,
    Activity,
    LAG(Activity) OVER (
      PARTITION BY Patient_ID
      ORDER BY Event_Order
    ) AS expected_previous_activity,
    LEAD(Activity) OVER (
      PARTITION BY Patient_ID
      ORDER BY Event_Order
    ) AS expected_next_activity,
    Previous_Activity,
    Next_Activity
  FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`
)
SELECT
  COUNTIF(
    NOT (
      (Previous_Activity IS NULL AND expected_previous_activity IS NULL)
      OR Previous_Activity = expected_previous_activity
    )
  ) AS incorrect_previous_activity,
  COUNTIF(
    NOT (
      (Next_Activity IS NULL AND expected_next_activity IS NULL)
      OR Next_Activity = expected_next_activity
    )
  ) AS incorrect_next_activity,
  CASE
    WHEN COUNTIF(
           NOT (
             (Previous_Activity IS NULL AND expected_previous_activity IS NULL)
             OR Previous_Activity = expected_previous_activity
           )
         ) = 0
     AND COUNTIF(
           NOT (
             (Next_Activity IS NULL AND expected_next_activity IS NULL)
             OR Next_Activity = expected_next_activity
           )
         ) = 0
    THEN 'PASS'
    ELSE 'FAIL'
  END AS validation_status
FROM ordered_events;


-- ============================================================
-- 9. WAITING-TIME VALIDATION
-- Negative waiting time should not occur.
-- ============================================================

SELECT
  COUNTIF(wait_time_minutes < 0) AS negative_wait_times,
  ROUND(AVG(wait_time_minutes), 2) AS average_wait_minutes,
  MAX(wait_time_minutes) AS maximum_wait_minutes,
  CASE
    WHEN COUNTIF(wait_time_minutes < 0) = 0
    THEN 'PASS'
    ELSE 'FAIL'
  END AS validation_status
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`;


-- High waiting-time events for review
SELECT
  Event_ID,
  Patient_ID,
  Activity,
  Department,
  wait_time_minutes,
  wait_category
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`
WHERE wait_time_minutes > 30
ORDER BY wait_time_minutes DESC
LIMIT 100;


-- ============================================================
-- 10. REWORK VALIDATION
-- Review rework flags and derived rework status.
-- ============================================================

SELECT
  Rework_Flag,
  rework_status,
  COUNT(*) AS event_count
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`
GROUP BY Rework_Flag, rework_status
ORDER BY event_count DESC;


-- ============================================================
-- 11. ACTIVITY AND DEPARTMENT VALIDATION
-- ============================================================

-- Activity-wise event count
SELECT
  Activity,
  COUNT(*) AS event_count
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`
GROUP BY Activity
ORDER BY event_count DESC;


-- Department-wise event count
SELECT
  Department,
  COUNT(*) AS event_count,
  COUNT(DISTINCT Patient_ID) AS patients
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`
GROUP BY Department
ORDER BY event_count DESC;


-- ============================================================
-- 12. ACTIVITY TRANSITION VALIDATION
-- This output is used later by PM4Py/process discovery.
-- ============================================================

SELECT
  Previous_Activity,
  Activity AS Current_Activity,
  COUNT(*) AS transition_count
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`
WHERE Previous_Activity IS NOT NULL
GROUP BY Previous_Activity, Activity
ORDER BY transition_count DESC
LIMIT 100;


-- ============================================================
-- 13. DERIVED FIELD VALIDATION
-- ============================================================

SELECT
  wait_category,
  rework_status,
  activity_priority,
  COUNT(*) AS records
FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`
GROUP BY wait_category, rework_status, activity_priority
ORDER BY records DESC;


-- ============================================================
-- 14. FINAL VALIDATION SUMMARY
-- A single summary showing whether the main checks pass.
-- ============================================================

WITH base AS (
  SELECT *
  FROM `careflow-process-mining.careflow_staging.int_normalized_event_log`
),
ordered AS (
  SELECT
    *,
    LAG(Event_Order) OVER (
      PARTITION BY Patient_ID
      ORDER BY Event_Order
    ) AS previous_event_order,
    LAG(event_timestamp) OVER (
      PARTITION BY Patient_ID
      ORDER BY Event_Order
    ) AS previous_timestamp
  FROM base
),
checks AS (
  SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT Event_ID) AS unique_event_ids,
    COUNTIF(Event_ID IS NULL) AS null_event_ids,
    COUNTIF(Patient_ID IS NULL) AS null_patient_ids,
    COUNTIF(Activity IS NULL) AS null_activities,
    COUNTIF(event_timestamp IS NULL) AS null_timestamps,
    COUNTIF(Department IS NULL) AS null_departments,
    COUNTIF(previous_event_order IS NOT NULL
            AND Event_Order <= previous_event_order) AS invalid_event_order,
    COUNTIF(previous_timestamp IS NOT NULL
            AND event_timestamp < previous_timestamp) AS invalid_timestamps,
    COUNTIF(wait_time_minutes < 0) AS negative_wait_times
  FROM ordered
)
SELECT
  total_records,
  unique_event_ids,
  null_event_ids,
  null_patient_ids,
  null_activities,
  null_timestamps,
  null_departments,
  invalid_event_order,
  invalid_timestamps,
  negative_wait_times,
  CASE
    WHEN total_records > 0
     AND total_records = unique_event_ids
     AND null_event_ids = 0
     AND null_patient_ids = 0
     AND null_activities = 0
     AND null_timestamps = 0
     AND null_departments = 0
     AND invalid_event_order = 0
     AND invalid_timestamps = 0
     AND negative_wait_times = 0
    THEN 'PASS - DBT OUTPUT READY FOR PM4PY'
    ELSE 'FAIL - REVIEW VALIDATION RESULTS'
  END AS final_validation_status
FROM checks;


-- ============================================================
-- END OF MEMBER 4 - DAY 7 VALIDATION
-- ============================================================
