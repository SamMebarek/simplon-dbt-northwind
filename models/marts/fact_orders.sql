SELECT
    order_id,
    customer_id,
    employee_id,
    ship_via,
    order_date,
    required_date,
    shipped_date,
    ship_city,
    ship_country,
    freight,
    is_shipped,
    is_on_time,
    delai_livraison_jours,
    nb_articles,
    quantite_totale,
    montant_total,

    ROUND(montant_total + COALESCE(freight, 0), 2) AS montant_total_avec_frais

FROM {{ ref('int_orders_enriched') }}