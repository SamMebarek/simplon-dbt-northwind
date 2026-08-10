SELECT
    CAST(employee_id AS INTEGER) AS employee_id,

    LOWER(
        TRIM(CONCAT(COALESCE(first_name, ''), ' ', COALESCE(last_name, '')))
    ) AS full_name,

    LOWER(TRIM(title)) AS title,
    CAST(hire_date AS DATE) AS hire_date,
    LOWER(TRIM(city)) AS city,
    LOWER(TRIM(country)) AS country
FROM {{ source('northwind', 'employees') }}