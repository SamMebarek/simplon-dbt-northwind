SELECT
    order_id,
    montant_total,
    montant_total_avec_frais
FROM {{ ref('fact_orders') }}
WHERE montant_total_avec_frais < montant_total