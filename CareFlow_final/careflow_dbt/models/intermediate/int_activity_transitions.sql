{{ config(materialized='table') }}

WITH transitions AS (

    SELECT
        patient_id,
        activity AS from_activity,

        LEAD(activity) OVER (
            PARTITION BY patient_id
            ORDER BY event_timestamp
        ) AS to_activity,

        event_timestamp AS from_timestamp,

        LEAD(event_timestamp) OVER (
            PARTITION BY patient_id
            ORDER BY event_timestamp
        ) AS to_timestamp

    FROM {{ ref('int_ordered_events') }}

)

SELECT
    patient_id,
    from_activity,
    to_activity,
    from_timestamp,
    to_timestamp

FROM transitions

WHERE to_activity IS NOT NULL