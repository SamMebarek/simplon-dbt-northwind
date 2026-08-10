SELECT
    employee_id,
    full_name,
    title,
    hire_date,
    city,
    country
FROM {{ ref('stg_employees') }}