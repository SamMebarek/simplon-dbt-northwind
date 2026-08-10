SELECT
    p.product_id,
    p.product_name,
    p.unit_price,
    p.units_in_stock,
    p.units_on_order,
    p.discontinued,
    p.en_stock,

    c.category_name,
    c.description AS category_description,

    s.company_name AS supplier_name,
    s.country AS supplier_country

FROM {{ ref('stg_products') }} AS p

LEFT JOIN {{ ref('stg_categories') }} AS c
    ON p.category_id = c.category_id

LEFT JOIN {{ ref('stg_suppliers') }} AS s
    ON p.supplier_id = s.supplier_id