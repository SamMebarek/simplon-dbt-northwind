SELECT
    LOWER(TRIM(customer_id)) AS customer_id,
    LOWER(TRIM(company_name)) AS company_name,
    LOWER(TRIM(contact_name)) AS contact_name,
    LOWER(TRIM(contact_title)) AS contact_title,
    LOWER(TRIM(city)) AS city,
    LOWER(TRIM(country)) AS country,
    TRIM(phone) AS phone
FROM {{ source('northwind', 'customers') }}