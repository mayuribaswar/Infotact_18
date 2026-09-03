
SELECT *

FROM {{ ref('fct_process_bottlenecks') }}

WHERE avg_transition_time_minutes < 0

   OR min_transition_time_minutes < 0

   OR max_transition_time_minutes < 0

   OR transition_count <= 0

