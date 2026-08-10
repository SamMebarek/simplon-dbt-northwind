SELECT
    p.product_id,
    COALESCE(SUM(od.quantity), 0) AS quantite_totale_vendue,
    COALESCE(ROUND(SUM(od.sous_total), 2), 0) AS ca_genere,
    COUNT(DISTINCT od.order_id) AS nb_commandes_distinctes,
    p.units_in_stock AS stock_restant

FROM {{ ref('stg_products') }} AS p

LEFT JOIN {{ ref('stg_order_details') }} AS od
    ON p.product_id = od.product_id

GROUP BY
    p.product_id,
    p.units_in_stock