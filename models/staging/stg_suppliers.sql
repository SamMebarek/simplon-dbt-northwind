SELECT
    CAST(supplier_id AS INTEGER) AS supplier_id,
    LOWER(TRIM(company_name)) AS company_name,
    LOWER(TRIM(contact_name)) AS contact_name,
    LOWER(TRIM(city)) AS city,
    LOWER(TRIM(country)) AS country,
    TRIM(phone) AS phone
FROM {{ source('northwind', 'suppliers') }}