
{{ config(materialized='table') }}

WITH ordered_events AS (

    SELECT
        Event_ID,
        Patient_ID,
        Activity,
        event_timestamp,
        wait_category,
        rework_status,
        activity_priority,

        ROW_NUMBER() OVER (
            PARTITION BY Patient_ID
            ORDER BY event_timestamp, Event_ID
        ) AS event_order

    FROM {{ ref('int_normalized_event_log') }}

)

SELECT
    Event_ID,
    Patient_ID,
    Activity,
    event_timestamp,
    wait_category,
    rework_status,
    activity_priority,
    event_order

FROM ordered_events

