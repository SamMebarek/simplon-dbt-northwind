SELECT
    f.order_id,
    f.order_date
FROM {{ ref('fact_orders') }} AS f

LEFT JOIN {{ ref('dim_temps') }} AS d
    ON f.order_date = d.date_id

WHERE d.date_id IS NULL