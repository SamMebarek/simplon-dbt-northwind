WITH employee_orders AS (

    SELECT
        employee_id,
        COUNT(order_id) AS nb_commandes_traitees,
        COALESCE(SUM(montant_total), 0) AS ca_total,
        ROUND(100.0 * AVG(CASE WHEN is_on_time THEN 1 ELSE 0 END), 2) AS taux_livraison_a_temps,
        ROUND(AVG(delai_livraison_jours), 2) AS delai_moyen_livraison_jours

    FROM {{ ref('int_orders_enriched') }}
    GROUP BY employee_id

)

SELECT
    e.employee_id,
    COALESCE(eo.nb_commandes_traitees, 0) AS nb_commandes_traitees,
    COALESCE(eo.ca_total, 0) AS ca_total,
    COALESCE(eo.taux_livraison_a_temps, 0) AS taux_livraison_a_temps,
    eo.delai_moyen_livraison_jours

FROM {{ ref('stg_employees') }} AS e

LEFT JOIN employee_orders AS eo
    ON e.employee_id = eo.employee_id