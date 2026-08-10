SELECT
    CAST(category_id AS INTEGER) AS category_id,
    LOWER(TRIM(category_name)) AS category_name,
    LOWER(TRIM(description)) AS description
FROM {{ source('northwind', 'categories') }}