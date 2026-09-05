{{ config(materialized='table') }}

WITH transitions AS (

    SELECT
        Patient_ID,
        Activity AS from_activity,

        LEAD(Activity) OVER (
            PARTITION BY Patient_ID
            ORDER BY event_order
        ) AS to_activity,

        event_timestamp AS from_timestamp,

        LEAD(event_timestamp) OVER (
            PARTITION BY Patient_ID
            ORDER BY event_order
        ) AS to_timestamp

    FROM {{ ref('int_ordered_events') }}

)

SELECT
    Patient_ID,
    from_activity,
    to_activity,
    from_timestamp,
    to_timestamp,
    TIMESTAMP_DIFF(to_timestamp, from_timestamp, MINUTE) AS transition_time_minutes

FROM transitions

WHERE to_activity IS NOT NULL