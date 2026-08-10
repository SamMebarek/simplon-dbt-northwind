SELECT
    CAST(order_id AS INTEGER) AS order_id,
    CAST(product_id AS INTEGER) AS product_id,
    CAST(unit_price AS NUMERIC(10, 2)) AS unit_price,
    CAST(quantity AS INTEGER) AS quantity,
    CAST(discount AS NUMERIC(5, 3)) AS discount,

    CAST(
        unit_price * quantity * (1 - discount)
        AS NUMERIC(12, 2)
    ) AS sous_total

FROM {{ source('northwind', 'order_details') }}