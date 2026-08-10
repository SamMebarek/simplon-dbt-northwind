# Northwind Analytics avec dbt et PostgreSQL

Projet de transformation et de modélisation des données **Northwind** avec **PostgreSQL**, **dbt Core** et **dbt-postgres**.

L’objectif est de partir des tables transactionnelles du schéma `public`, de nettoyer et enrichir les données, puis de construire des dimensions et une table de faits prêtes pour l’analyse.

## Architecture

Le projet suit une architecture en trois couches :

```text
Sources PostgreSQL (public)
        ↓
Staging : nettoyage et standardisation
        ↓
Intermediate : jointures et calculs préparatoires
        ↓
Marts : dimensions et table de faits
```

## Sources Northwind

Les huit tables déclarées dans `models/staging/sources.yml` sont :

- `customers`
- `orders`
- `order_details`
- `products`
- `categories`
- `suppliers`
- `employees`
- `shippers`

## Structure du projet

```text
models/
├── staging/
│   ├── sources.yml
│   ├── schema.yml
│   ├── stg_customers.sql
│   ├── stg_orders.sql
│   ├── stg_order_details.sql
│   ├── stg_products.sql
│   ├── stg_categories.sql
│   ├── stg_suppliers.sql
│   ├── stg_employees.sql
│   └── stg_shippers.sql
├── intermediate/
│   ├── int_orders_enriched.sql
│   ├── int_products_enriched.sql
│   ├── int_customers_stats.sql
│   ├── int_employee_stats.sql
│   ├── int_monthly_revenue.sql
│   └── int_product_sales.sql
└── marts/
    ├── schema.yml
    ├── dim_customers.sql
    ├── dim_products.sql
    ├── dim_employees.sql
    ├── dim_shippers.sql
    ├── dim_temps.sql
    └── fact_orders.sql

tests/
├── assert_montant_total_avec_frais.sql
└── assert_order_date_exists_in_dim_temps.sql
```

## Modèles staging

La couche staging contient un modèle par table source, sans jointure. Elle réalise uniquement le nettoyage, le renommage et la mise en cohérence des types.

- `stg_customers` : nettoyage des informations clients avec `TRIM` et standardisation de la casse.
- `stg_orders` : typage des commandes et création de `is_shipped`.
- `stg_order_details` : calcul du sous-total après remise.
- `stg_products` : création de l’indicateur booléen `en_stock`.
- `stg_employees` : création de `full_name` à partir du prénom et du nom.
- `stg_categories`, `stg_suppliers` et `stg_shippers` : nettoyage et standardisation des données de référence.

Le sous-total d’une ligne de commande est calculé ainsi :

```text
unit_price × quantity × (1 - discount)
```

## Modèles intermediate

La couche intermediate utilise uniquement des `ref()` et prépare les données nécessaires aux marts :

- `int_orders_enriched` : agrégation par commande, quantité totale, nombre d’articles, montant total, délai de livraison et livraison à temps.
- `int_products_enriched` : enrichissement des produits avec leur catégorie et leur fournisseur.
- `int_customers_stats` : nombre de commandes, CA total, première et dernière commande, délai moyen entre commandes.
- `int_employee_stats` : commandes traitées, CA total, taux de livraison à temps et délai moyen de livraison.
- `int_monthly_revenue` : CA mensuel, panier moyen et variation par rapport au mois précédent.
- `int_product_sales` : quantité vendue, CA généré, nombre de commandes distinctes et stock restant par produit.

## Marts

La couche marts expose les modèles finaux destinés à l’analyse :

- `dim_customers` : dimension clients.
- `dim_products` : dimension produits enrichie avec une classification par gamme.
- `dim_employees` : dimension employés.
- `dim_shippers` : dimension transporteurs.
- `dim_temps` : dimension temporelle construite depuis les dates de commandes.
- `fact_orders` : table de faits des commandes avec le montant total incluant les frais de transport.

### Gammes de produits

| Gamme | Prix unitaire |
|---|---:|
| Entrée de gamme | Jusqu’à 88 € |
| Milieu de gamme | De plus de 88 € à 169 € |
| Premium | Plus de 169 € |

## Tests de qualité

Le projet comprend :

- des tests `not_null` et `unique` sur les clés primaires des modèles staging ;
- un contrôle d’unicité sur la clé composée `order_id` + `product_id` de `stg_order_details` ;
- des tests `relationships` entre `fact_orders` et les dimensions clients, employés et transporteurs ;
- un test `accepted_values` sur la colonne `gamme` ;
- des tests `not_null` sur `montant_total` et `freight` ;
- un test conditionnel sur `is_on_time`, limité aux commandes livrées ;
- un test singulier vérifiant que `montant_total_avec_frais` n’est jamais inférieur à `montant_total` ;
- un test singulier vérifiant que chaque date de commande existe dans `dim_temps`.

## Prérequis

- Python 3
- PostgreSQL
- dbt Core
- adaptateur `dbt-postgres`

> PostgreSQL n’étant pas pris en charge de manière stable par la version Fusion utilisée lors du projet, les commandes doivent être exécutées avec **dbt Core** depuis l’environnement virtuel.

## Installation

Créer et activer un environnement virtuel :

```bash
python -m venv .venv
```

Sous Windows PowerShell :

```powershell
.\.venv\Scripts\Activate.ps1
```

Sous Linux ou macOS :

```bash
source .venv/bin/activate
```

Installer les dépendances :

```bash
pip install -r requirements.txt
```

Exemple de `requirements.txt` :

```text
dbt-core
dbt-postgres
```

## Configuration PostgreSQL

La base utilisée est `northwind`. Deux rôles de groupe `NOLOGIN` permettent de séparer les accès :

- `northwwind_readonly` : lecture seule dans `public` ;
- `northwind_dbt` : lecture dans `public` et création des objets dbt dans `dbt_dev`.

Les utilisateurs associés sont :

- `analyste`, membre de `northwwind_readonly` ;
- `dbt_user`, membre de `northwind_dbt`.

Le mot de passe ne doit jamais être versionné. Il peut être fourni par une variable d’environnement dans `~/.dbt/profiles.yml` :

```yaml
northwind:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      port: 5432
      user: dbt_user
      password: "{{ env_var('DBT_POSTGRES_PASSWORD') }}"
      dbname: northwind
      schema: dbt_dev
      threads: 4
```

## Exécution

Vérifier la connexion :

```bash
dbt debug
```

Exécuter l’ensemble du projet et les tests :

```bash
dbt build
```

Exécuter une couche spécifique :

```bash
dbt run --select path:models/staging
dbt run --select path:models/intermediate
dbt run --select path:models/marts
```

Exécuter uniquement les tests :

```bash
dbt test
```

## Documentation et lineage

Générer puis afficher la documentation dbt :

```bash
dbt docs generate
dbt docs serve
```

L’interface est ensuite disponible par défaut sur `http://localhost:8080`. Elle permet de consulter la description des modèles, les tests et le graphe de dépendances entre les sources, le staging, les modèles intermediate et les marts.

## Analyses réalisées

Les modèles permettent notamment d’analyser :

- les produits les plus vendus et le CA généré ;
- le CA mensuel et ses variations mensuelles et annuelles ;
- les employés générant le plus de CA ;
- les pays et clients générant le plus de commandes ;
- les délais moyens des transporteurs ;
- le CA par catégorie de produits ;
- les clients inactifs depuis plus de 90 jours.

## Contrôles de cohérence

Des requêtes SQL complémentaires vérifient notamment que :

- le nombre de commandes de `fact_orders` correspond à celui de `public.orders` ;
- aucune commande ne référence un client ou un employé absent des dimensions ;
- toutes les dates de commandes existent dans `dim_temps` ;
- le CA de `fact_orders` est cohérent avec celui calculé depuis `public.order_details`.
