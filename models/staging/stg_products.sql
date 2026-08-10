SELECT
    CAST(product_id AS INTEGER) AS product_id,
    LOWER(TRIM(product_name)) AS product_name,
    CAST(supplier_id AS INTEGER) AS supplier_id,
    CAST(category_id AS INTEGER) AS category_id,
    CAST(unit_price AS NUMERIC(10, 2)) AS unit_price,
    CAST(units_in_stock AS INTEGER) AS units_in_stock,
    CAST(units_on_order AS INTEGER) AS units_on_order,
    CAST(discontinued AS BOOLEAN) AS discontinued,
    units_in_stock > 0 AS en_stock
FROM {{ source('northwind', 'products') }}