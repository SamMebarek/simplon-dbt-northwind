SELECT
    CAST(order_id AS INTEGER) AS order_id,
    LOWER(TRIM(customer_id)) AS customer_id,
    CAST(employee_id AS INTEGER) AS employee_id,
    CAST(ship_via AS INTEGER) AS ship_via,
    CAST(order_date AS DATE) AS order_date,
    CAST(required_date AS DATE) AS required_date,
    CAST(shipped_date AS DATE) AS shipped_date,
    LOWER(TRIM(ship_city)) AS ship_city,
    LOWER(TRIM(ship_country)) AS ship_country,
    CAST(freight AS NUMERIC(10, 2)) AS freight,
    shipped_date IS NOT NULL AS is_shipped
FROM {{ source('northwind', 'orders') }}