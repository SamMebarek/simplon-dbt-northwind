WITH orders_with_previous_date AS (

    SELECT
        customer_id,
        order_id,
        order_date,
        montant_total,

        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date, order_id) AS previous_order_date

    FROM {{ ref('int_orders_enriched') }}

),

customer_stats AS (

    SELECT
        customer_id,
        COUNT(order_id) AS nb_commandes,
        COALESCE(SUM(montant_total), 0) AS ca_total,
        MIN(order_date) AS date_premiere_commande,
        MAX(order_date) AS date_derniere_commande,

        ROUND(AVG(order_date - previous_order_date), 2) AS delai_moyen_entre_commandes

    FROM orders_with_previous_date
    GROUP BY customer_id

)

SELECT
    c.customer_id,
    COALESCE(cs.nb_commandes, 0) AS nb_commandes,
    COALESCE(cs.ca_total, 0) AS ca_total,
    cs.date_premiere_commande,
    cs.date_derniere_commande,
    cs.delai_moyen_entre_commandes

FROM {{ ref('stg_customers') }} AS c

LEFT JOIN customer_stats AS cs
    ON c.customer_id = cs.customer_id