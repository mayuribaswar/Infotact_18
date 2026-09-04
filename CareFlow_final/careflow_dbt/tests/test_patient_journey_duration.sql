SELECT *

FROM {{ ref('fct_patient_journey') }}

WHERE total_process_time_minutes < 0

   OR total_wait_time_minutes < 0

   OR avg_wait_time_minutes < 0

   OR total_activities <= 0