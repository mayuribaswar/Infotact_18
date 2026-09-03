
SELECT *

FROM {{ ref('fct_process_bottlenecks') }}

WHERE
    (bottleneck_level = 'High'
     AND bottleneck_score != 3)

 OR (bottleneck_level = 'Medium'
     AND bottleneck_score != 2)

 OR (bottleneck_level = 'Low'
     AND bottleneck_score != 1)

