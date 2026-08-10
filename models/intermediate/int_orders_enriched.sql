WITH order_details_aggregated AS (

    SELECT
        order_id,
        COUNT(product_id) AS nb_articles,
        COALESCE(SUM(quantity), 0) AS quantite_totale,
        COALESCE(SUM(sous_total), 0) AS montant_total
    FROM {{ ref('stg_order_details') }}
    GROUP BY order_id

)

SELECT
    o.order_id,
    o.customer_id,
    o.employee_id,
    o.ship_via,
    o.order_date,
    o.required_date,
    o.shipped_date,
    o.ship_city,
    o.ship_country,
    o.freight,
    o.is_shipped,

    CASE
        WHEN o.shipped_date IS NOT NULL
        THEN o.shipped_date - o.order_date
        ELSE NULL
    END AS delai_livraison_jours,

    CASE
        WHEN o.shipped_date IS NULL OR o.required_date IS NULL THEN FALSE
        ELSE o.shipped_date <= o.required_date
    END AS is_on_time,

    COALESCE(oda.nb_articles, 0) AS nb_articles,
    COALESCE(oda.quantite_totale, 0) AS quantite_totale,
    COALESCE(oda.montant_total, 0) AS montant_total

FROM {{ ref('stg_orders') }} AS o

LEFT JOIN order_details_aggregated AS oda
    ON o.order_id = oda.order_id