-- =========================================================
-- CAREFLOW - DAY 18
-- FINAL END-TO-END VALIDATION
-- =========================================================


-- =========================================================
-- 1. RAW VS STAGING
-- =========================================================

SELECT
    'RAW' AS layer,
    COUNT(*) AS record_count
FROM `careflow-process-mining.careflow_raw.hospital_event_log_raw`

UNION ALL

SELECT
    'STAGING' AS layer,
    COUNT(*) AS record_count
FROM `careflow-process-mining.careflow_staging.stg_hospital_event_log`;


-- =========================================================
-- 2. STAGING VS MART
-- =========================================================

SELECT
    'STAGING' AS layer,
    COUNT(*) AS record_count
FROM `careflow-process-mining.careflow_staging.stg_hospital_event_log`

UNION ALL

SELECT
    'MART' AS layer,
    COUNT(*) AS record_count
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`;


-- =========================================================
-- 3. UNIQUE PATIENT RECONCILIATION
-- =========================================================

SELECT
    'STAGING' AS layer,
    COUNT(DISTINCT patient_id) AS unique_patients
FROM `careflow-process-mining.careflow_staging.stg_hospital_event_log`

UNION ALL

SELECT
    'MART' AS layer,
    COUNT(DISTINCT patient_id) AS unique_patients
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`;


-- =========================================================
-- 4. FINAL NULL CHECK
-- =========================================================

SELECT
    COUNTIF(event_id IS NULL) AS null_event_id,
    COUNTIF(patient_id IS NULL) AS null_patient_id,
    COUNTIF(activity IS NULL) AS null_activity,
    COUNTIF(event_timestamp IS NULL) AS null_timestamp
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`;


-- =========================================================
-- 5. FINAL DUPLICATE CHECK
-- =========================================================

SELECT
    COUNT(*) AS duplicate_event_groups
FROM (
    SELECT
        event_id
    FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
    GROUP BY event_id
    HAVING COUNT(*) > 1
);


-- =========================================================
-- 6. FINAL ORPHAN CHECK
-- =========================================================

SELECT
    COUNT(*) AS orphan_events
FROM `careflow-process-mining.careflow_mart.fct_hospital_events` e
LEFT JOIN `careflow-process-mining.careflow_mart.dim_patients` p
    ON e.patient_id = p.patient_id
WHERE p.patient_id IS NULL;


-- =========================================================
-- 7. FINAL DATE RANGE
-- =========================================================

SELECT
    MIN(event_timestamp) AS first_event,
    MAX(event_timestamp) AS last_event
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`;


-- =========================================================
-- 8. FINAL ACTIVITY SUMMARY
-- =========================================================

SELECT
    activity,
    COUNT(*) AS event_count
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
GROUP BY activity
ORDER BY event_count DESC;


-- =========================================================
-- 9. FINAL PATIENT SUMMARY
-- =========================================================

SELECT
    COUNT(DISTINCT patient_id) AS total_patients,
    COUNT(*) AS total_events,
    COUNT(DISTINCT activity) AS total_activities
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`;

-- =========================================================
-- CAREFLOW - DAY 18
-- MEMBER 4 - VALIDATE CONFORMANCE INPUT
-- =========================================================
-- Purpose:
-- Validate that the MART event log is ready to be used as
-- the actual patient journey input for conformance checking.
--
-- Validation covered:
-- 1. Actual journey completeness
-- 2. Patient-level event sequence
-- 3. Sequence length
-- 4. Patients with only one event
-- 5. Repeated consecutive activities
-- 6. Journey start/end activities
-- 7. Invalid chronological ordering
-- 8. Conformance-input readiness summary
--
-- NOTE:
-- This source file does not define a separate "ideal journey"
-- table. Therefore this section validates the ACTUAL journey
-- input only and prepares it for comparison with the mandated/
-- ideal journey when that source is available.
-- =========================================================


-- =========================================================
-- 10. ACTUAL JOURNEY INPUT
-- =========================================================

WITH ordered_events AS (
    SELECT
        patient_id,
        event_id,
        activity,
        event_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY patient_id
            ORDER BY event_timestamp, event_id
        ) AS event_order
    FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
)
SELECT
    patient_id,
    event_order,
    event_id,
    activity,
    event_timestamp
FROM ordered_events
ORDER BY patient_id, event_order;


-- =========================================================
-- 11. PATIENT JOURNEY SEQUENCE
-- =========================================================
-- Creates one actual activity path per patient.

SELECT
    patient_id,
    STRING_AGG(
        activity,
        ' -> '
        ORDER BY event_timestamp, event_id
    ) AS actual_journey,
    COUNT(*) AS event_count
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
GROUP BY patient_id
ORDER BY patient_id;


-- =========================================================
-- 12. JOURNEY LENGTH VALIDATION
-- =========================================================

SELECT
    COUNT(*) AS total_patients,
    COUNTIF(event_count = 1) AS single_event_patients,
    COUNTIF(event_count > 1) AS multi_event_patients,
    MIN(event_count) AS minimum_events_per_patient,
    MAX(event_count) AS maximum_events_per_patient,
    AVG(event_count) AS average_events_per_patient
FROM (
    SELECT
        patient_id,
        COUNT(*) AS event_count
    FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
    GROUP BY patient_id
);


-- =========================================================
-- 13. SINGLE-EVENT PATIENTS
-- =========================================================
-- These journeys may provide insufficient sequence information
-- for meaningful conformance analysis.

SELECT
    patient_id,
    COUNT(*) AS event_count
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
GROUP BY patient_id
HAVING COUNT(*) = 1
ORDER BY patient_id;


-- =========================================================
-- 14. CONSECUTIVE REPEATED ACTIVITIES
-- =========================================================
-- Detects patterns such as Doctor -> Doctor.
-- These are not automatically errors, but should be reviewed.

WITH ordered_events AS (
    SELECT
        patient_id,
        event_id,
        activity,
        event_timestamp,
        LAG(activity) OVER (
            PARTITION BY patient_id
            ORDER BY event_timestamp, event_id
        ) AS previous_activity
    FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
)
SELECT
    patient_id,
    event_id,
    previous_activity,
    activity,
    event_timestamp
FROM ordered_events
WHERE previous_activity = activity
ORDER BY patient_id, event_timestamp, event_id;


-- =========================================================
-- 15. JOURNEY START / END ACTIVITIES
-- =========================================================

WITH ranked_events AS (
    SELECT
        patient_id,
        activity,
        event_timestamp,
        event_id,
        ROW_NUMBER() OVER (
            PARTITION BY patient_id
            ORDER BY event_timestamp, event_id
        ) AS first_rank,
        ROW_NUMBER() OVER (
            PARTITION BY patient_id
            ORDER BY event_timestamp DESC, event_id DESC
        ) AS last_rank
    FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
)
SELECT
    patient_id,
    MAX(IF(first_rank = 1, activity, NULL)) AS journey_start_activity,
    MAX(IF(last_rank = 1, activity, NULL)) AS journey_end_activity
FROM ranked_events
GROUP BY patient_id
ORDER BY patient_id;


-- =========================================================
-- 16. INVALID CHRONOLOGICAL ORDERING
-- =========================================================
-- Checks whether an event timestamp is earlier than the
-- previous event timestamp for the same patient.

WITH ordered_events AS (
    SELECT
        patient_id,
        event_id,
        activity,
        event_timestamp,
        LAG(event_timestamp) OVER (
            PARTITION BY patient_id
            ORDER BY event_timestamp, event_id
        ) AS previous_timestamp
    FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
)
SELECT
    patient_id,
    event_id,
    activity,
    previous_timestamp,
    event_timestamp
FROM ordered_events
WHERE previous_timestamp IS NOT NULL
  AND event_timestamp < previous_timestamp
ORDER BY patient_id, event_timestamp, event_id;


-- =========================================================
-- 17. CONFORMANCE INPUT READINESS SUMMARY
-- =========================================================
-- A clean actual-journey input should have:
--   null_event_ids = 0
--   null_patient_ids = 0
--   null_activities = 0
--   null_timestamps = 0
--   duplicate_event_groups = 0
--   orphan_events = 0
--
-- Additional journey-quality counts are included below.

WITH event_quality AS (
    SELECT
        COUNTIF(event_id IS NULL) AS null_event_ids,
        COUNTIF(patient_id IS NULL) AS null_patient_ids,
        COUNTIF(activity IS NULL) AS null_activities,
        COUNTIF(event_timestamp IS NULL) AS null_timestamps
    FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
),
duplicate_events AS (
    SELECT COUNT(*) AS duplicate_event_groups
    FROM (
        SELECT event_id
        FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
        GROUP BY event_id
        HAVING COUNT(*) > 1
    )
),
orphan_events AS (
    SELECT COUNT(*) AS orphan_event_count
    FROM `careflow-process-mining.careflow_mart.fct_hospital_events` e
    LEFT JOIN `careflow-process-mining.careflow_mart.dim_patients` p
        ON e.patient_id = p.patient_id
    WHERE p.patient_id IS NULL
),
single_event_patients AS (
    SELECT COUNT(*) AS single_event_patient_count
    FROM (
        SELECT patient_id
        FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
        GROUP BY patient_id
        HAVING COUNT(*) = 1
    )
),
repeated_consecutive_activities AS (
    SELECT COUNT(*) AS repeated_consecutive_count
    FROM (
        SELECT
            patient_id,
            event_id,
            activity,
            LAG(activity) OVER (
                PARTITION BY patient_id
                ORDER BY event_timestamp, event_id
            ) AS previous_activity
        FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
    )
    WHERE previous_activity = activity
)
SELECT
    null_event_ids,
    null_patient_ids,
    null_activities,
    null_timestamps,
    duplicate_event_groups,
    orphan_event_count,
    single_event_patient_count,
    repeated_consecutive_count,
    CASE
        WHEN null_event_ids = 0
         AND null_patient_ids = 0
         AND null_activities = 0
         AND null_timestamps = 0
         AND duplicate_event_groups = 0
         AND orphan_event_count = 0
        THEN 'READY_FOR_CONFORMANCE_INPUT'
        ELSE 'REVIEW_REQUIRED'
    END AS conformance_input_status
FROM event_quality
CROSS JOIN duplicate_events
CROSS JOIN orphan_events
CROSS JOIN single_event_patients
CROSS JOIN repeated_consecutive_activities;


-- =========================================================
-- 18. POWER BI / PM4PY CONFORMANCE INPUT DATASET
-- =========================================================
-- This is the clean event-level input shape:
-- Case identifier = patient_id
-- Activity         = activity
-- Timestamp        = event_timestamp

SELECT
    patient_id AS case_id,
    activity,
    event_timestamp AS timestamp,
    event_id
FROM `careflow-process-mining.careflow_mart.fct_hospital_events`
WHERE patient_id IS NOT NULL
  AND activity IS NOT NULL
  AND event_timestamp IS NOT NULL
  AND event_id IS NOT NULL
ORDER BY case_id, timestamp, event_id;
