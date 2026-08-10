-- quel employé a généré le plus de CA total?

SELECT
    es.employee_id,
    e.full_name,
    es.ca_total
FROM dbt_dev.int_employee_stats AS es
INNER JOIN dbt_dev.dim_employees AS e
    ON es.employee_id = e.employee_id
ORDER BY es.ca_total DESC
LIMIT 1;

--quel pays genère le plus de commandes?


SELECT
    c.country,
    COUNT(f.order_id) AS nb_commandes
FROM dbt_dev.fact_orders AS f
INNER JOIN dbt_dev.dim_customers AS c
    ON f.customer_id = c.customer_id
GROUP BY c.country
ORDER BY nb_commandes DESC
LIMIT 1;

--quel client genère le plus de commandes?

SELECT
    c.customer_id,
    c.company_name,
    COUNT(f.order_id) AS nb_commandes
FROM dbt_dev.fact_orders AS f
INNER JOIN dbt_dev.dim_customers AS c
    ON f.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.company_name
ORDER BY nb_commandes DESC
LIMIT 1;


--quel transporteur a le meilleur délais de livraison?


SELECT
    s.shipper_id,
    s.company_name,
    ROUND(AVG(f.delai_livraison_jours), 2) AS delai_moyen_livraison
FROM dbt_dev.fact_orders AS f
INNER JOIN dbt_dev.dim_shippers AS s
    ON f.ship_via = s.shipper_id
WHERE f.delai_livraison_jours IS NOT NULL
GROUP BY
    s.shipper_id,
    s.company_name
ORDER BY delai_moyen_livraison ASC
LIMIT 1;

--quelle catégorie de produit est la plus rentable?

SELECT
    p.category_name,
    ROUND(SUM(ps.ca_genere), 2) AS ca_total
FROM dbt_dev.int_product_sales AS ps
INNER JOIN dbt_dev.dim_products AS p
    ON ps.product_id = p.product_id
GROUP BY p.category_name
ORDER BY ca_total DESC
LIMIT 1;


--1 - Vérifier que le nombre total de commandes dans fact_orders est identique au nombre de commandes dans la table source orders


SELECT
    (SELECT COUNT(*) FROM public.orders) AS nb_commandes_source,
    (SELECT COUNT(*) FROM dbt_dev.fact_orders) AS nb_commandes_fact,
    (SELECT COUNT(*) FROM public.orders)
        = (SELECT COUNT(*) FROM dbt_dev.fact_orders) AS nombres_identiques;

--2 - Vérifier qu'aucune commande dans fact_orders ne référence un client absent de dim_customers

SELECT
    f.order_id,
    f.customer_id
FROM dbt_dev.fact_orders AS f
LEFT JOIN dbt_dev.dim_customers AS c
    ON f.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

--3 - Vérifier qu'aucune date de commande dans fact_orders n'est absente de dim_temps

SELECT
    f.order_id,
    f.order_date
FROM dbt_dev.fact_orders AS f
LEFT JOIN dbt_dev.dim_temps AS d
    ON f.order_date = d.date_id
WHERE d.date_id IS NULL;

--4 - Vérifier que le CA total calculé depuis fact_orders est cohérent avec le CA calculé directement depuis order_details en OLTP

WITH ca_fact_orders AS (
    SELECT
        ROUND(SUM(montant_total), 2) AS ca_total
    FROM dbt_dev.fact_orders
),

ca_order_details AS (
    SELECT
        ROUND(SUM(ROUND((unit_price * quantity * (1 - discount))::NUMERIC, 2)), 2) AS ca_total
    FROM public.order_details
)

SELECT
    f.ca_total AS ca_fact_orders,
    o.ca_total AS ca_order_details,
    ROUND(f.ca_total - o.ca_total, 2) AS difference,
    f.ca_total = o.ca_total AS ca_egal
FROM ca_fact_orders AS f
CROSS JOIN ca_order_details AS o;


--5 - Vérifier qu'aucun employé présent dans fact_orders n'est absent de dim_employees

SELECT
    f.order_id,
    f.employee_id
FROM dbt_dev.fact_orders AS f
LEFT JOIN dbt_dev.dim_employees AS e
    ON f.employee_id = e.employee_id
WHERE e.employee_id IS NULL;