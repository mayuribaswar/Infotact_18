{{ config(
    materialized='table'
) }}

WITH ordered_events AS (

    SELECT
        e.Event_ID,
        e.Patient_ID,
        e.Activity,
        n.Department,
        e.event_timestamp,
        n.wait_time_minutes,
        n.Severity,
        n.Activity_Status,
        e.event_order,

        LEAD(e.Activity) OVER (
            PARTITION BY e.Patient_ID
            ORDER BY e.event_order
        ) AS next_activity,

        LEAD(e.event_timestamp) OVER (
            PARTITION BY e.Patient_ID
            ORDER BY e.event_order
        ) AS next_timestamp,

        LEAD(n.Department) OVER (
            PARTITION BY e.Patient_ID
            ORDER BY e.event_order
        ) AS next_department

    FROM {{ ref('int_ordered_events') }} e
    INNER JOIN {{ ref('int_normalized_event_log') }} n
        ON e.Event_ID = n.Event_ID

),

transitions AS (

    SELECT
        Event_ID,
        Patient_ID,
        Activity AS activity_from,
        next_activity AS activity_to,
        Department AS department_from,
        next_department AS department_to,
        event_timestamp AS timestamp_from,
        next_timestamp AS timestamp_to,
        TIMESTAMP_DIFF(
            next_timestamp,
            event_timestamp,
            MINUTE
        ) AS transition_time_minutes,
        wait_time_minutes AS source_wait_time_minutes,
        Severity,
        Activity_Status

    FROM ordered_events
    WHERE next_activity IS NOT NULL
      AND next_timestamp IS NOT NULL

)

SELECT
    activity_from,
    activity_to,
    COUNT(*) AS transition_count,
    COUNT(DISTINCT Patient_ID) AS patient_count,
    ROUND(AVG(transition_time_minutes), 2) AS avg_transition_time_minutes,
    MIN(transition_time_minutes) AS min_transition_time_minutes,
    MAX(transition_time_minutes) AS max_transition_time_minutes,
    APPROX_QUANTILES(transition_time_minutes, 100)[OFFSET(50)] AS median_transition_time_minutes,
    APPROX_QUANTILES(transition_time_minutes, 100)[OFFSET(90)] AS p90_transition_time_minutes,
    ROUND(AVG(source_wait_time_minutes), 2) AS avg_source_wait_time_minutes

FROM transitions
WHERE transition_time_minutes >= 0
GROUP BY
    activity_from,
    activity_to