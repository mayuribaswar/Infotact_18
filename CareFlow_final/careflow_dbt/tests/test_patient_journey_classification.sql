SELECT *

FROM {{ ref('fct_patient_journey') }}

WHERE
       (
           process_performance = 'Fast'
           AND (
               total_process_time_minutes < 0
               OR total_process_time_minutes >= 60
           )
       )

    OR (
           process_performance = 'Moderate'
           AND (
               total_process_time_minutes < 60
               OR total_process_time_minutes > 180
           )
       )

    OR (
           process_performance = 'Slow'
           AND total_process_time_minutes <= 180
       )