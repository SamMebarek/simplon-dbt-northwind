SELECT DISTINCT
    order_date AS date_id,
    EXTRACT(DAY FROM order_date)::INTEGER AS jour,
    EXTRACT(MONTH FROM order_date)::INTEGER AS mois,
    EXTRACT(YEAR FROM order_date)::INTEGER AS annee,
    EXTRACT(QUARTER FROM order_date)::INTEGER AS trimestre,
    TO_CHAR(order_date, 'YYYY-MM') AS annee_mois,

    CASE
        WHEN EXTRACT(ISODOW FROM order_date) IN (6, 7) THEN TRUE
        ELSE FALSE
    END AS est_weekend

FROM {{ ref('stg_orders') }}

WHERE order_date IS NOT NULL