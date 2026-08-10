WITH monthly_revenue AS (

    SELECT
        DATE_TRUNC('month', order_date)::DATE AS mois,
        COUNT(order_id) AS nb_commandes,
        ROUND(SUM(montant_total), 2) AS ca_mensuel,
        ROUND(AVG(montant_total), 2) AS panier_moyen

    FROM {{ ref('int_orders_enriched') }}

    WHERE order_date IS NOT NULL

    GROUP BY DATE_TRUNC('month', order_date)

),

monthly_with_previous AS (

    SELECT
        mois,
        nb_commandes,
        ca_mensuel,
        panier_moyen,
        LAG(ca_mensuel) OVER (ORDER BY mois) AS ca_mois_precedent

    FROM monthly_revenue

)

SELECT
    mois,
    nb_commandes,
    ca_mensuel,
    panier_moyen,
    ca_mois_precedent,
    ROUND(100.0 * (ca_mensuel - ca_mois_precedent)/ NULLIF(ca_mois_precedent, 0),2) AS variation_pct

FROM monthly_with_previous