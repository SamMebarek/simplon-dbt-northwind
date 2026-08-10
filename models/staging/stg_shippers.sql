SELECT
    CAST(shipper_id AS INTEGER) AS shipper_id,
    LOWER(TRIM(company_name)) AS company_name,
    TRIM(phone) AS phone
FROM {{ source('northwind', 'shippers') }}