# ecommerce-elt-dbt-duckdb

![CI](https://github.com/LuisEnrique98/ecommerce-elt-dbt-duckdb/actions/workflows/ci.yml/badge.svg)

End-to-end ELT pipeline: Python ingestion, DuckDB storage and dbt transformations (dimensional model and data quality tests) on the Olist e-commerce dataset.

> **Estado:** Pipeline funcional; dashboard en progreso. Ver el [roadmap](#roadmap) para saber qué está terminado.

## Objetivo

Construir de punta a punta un flujo de datos como el de un entorno real: cargar datos crudos, limpiarlos y tipificarlos por capas, modelarlos de forma dimensional y validar su calidad, para responder preguntas de negocio de un e-commerce:

- ¿Cuánto se vende por mes y por categoría de producto?
- ¿Qué vendedores rinden mejor y cuáles entregan tarde?
- ¿Cuánto tarda la entrega frente a la fecha estimada?
- ¿Qué proporción de clientes compra más de una vez?

## Arquitectura

```
CSV (Olist) → Python (ingesta) → DuckDB (esquema raw)
            → dbt staging (limpieza y tipado)
            → dbt marts (modelo dimensional)
            → tests de calidad
```

Modelo dimensional previsto:

- **Hecho:** `fct_order_items`
- **Dimensiones:** `dim_customers`, `dim_products`, `dim_sellers`, `dim_date`

## Stack

- **Python** para la ingesta
- **DuckDB** como almacén analítico local
- **dbt-core** (adaptador `dbt-duckdb`) para transformaciones y tests
- **Git / GitHub** para control de versiones

## Dataset

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce/data), publicado en Kaggle por Olist.

Licencia del dataset: [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/). Este proyecto se usa con fines educativos y de portafolio, no comerciales. Los datos **no se incluyen en este repositorio**; deben descargarse desde Kaggle.

El código de este repositorio se distribuye bajo licencia MIT (ver `LICENSE`). La licencia del dataset aplica únicamente a los datos.

## Estructura del repositorio

```
.
├── .github/workflows/ci.yml   # pipeline automático
├── data/raw/                  # CSV (no versionado)
├── ingestion/ingest.py
├── dbt_project/
│   ├── models/staging/        # 8 modelos + tests
│   ├── models/marts/          # fct_order_items + 4 dimensiones
│   └── tests/                 # test de clave compuesta
├── requirements.txt
└── README.md
```

## Cómo ejecutarlo

**1. Clonar el repositorio y crear el entorno**

```bash
git clone https://github.com/LuisEnrique98/ecommerce-elt-dbt-duckdb.git
cd ecommerce-elt-dbt-duckdb
python -m venv .venv
.venv\Scripts\activate        # Windows
pip install -r requirements.txt
```

**2. Descargar el dataset**

Descargar el ZIP desde Kaggle (enlace de la sección Dataset) y extraer los 9 archivos CSV en `data/raw/`.

**3. Cargar los datos crudos a DuckDB**

Desde la raíz del proyecto:

```bash
python ingestion/ingest.py
```

Crea `olist.duckdb` con el esquema `raw`. El script es idempotente: puede ejecutarse varias veces sin duplicar datos.

**4. Ejecutar las transformaciones con dbt**

```bash
cd dbt_project
dbt run --profiles-dir .
dbt test --profiles-dir .
```

## Decisiones de diseño

- **ELT en lugar de ETL:** los datos se cargan tal cual al esquema `raw` y la transformación ocurre dentro del almacén con dbt, lo que deja trazable cada paso.
- **Capas separadas:** `raw` (sin tocar), `staging` (limpieza y tipado, una vista por tabla) y `marts` (modelo de negocio materializado como tablas).
- **DuckDB:** no requiere servidor ni credenciales, consume poca memoria y permite reproducir el proyecto en cualquier equipo.
- **Ingesta idempotente:** `CREATE OR REPLACE TABLE` permite relanzar la carga sin efectos secundarios.

## Calidad de datos

38 tests en dbt: unicidad, no nulos, integridad referencial entre tablas,
valores aceptados y un test de clave compuesta en `order_items`.

**Hallazgo:** 789 valores de `review_id` aparecen repetidos en el dataset
original. El test está configurado como advertencia (`warn`) en staging,
que solo refleja los datos tal como llegan; el tratamiento se define en la capa
de negocio.

## Roadmap

- [x] Entorno y estructura del repositorio
- [x] Ingesta de los 9 CSV a DuckDB
- [x] Capa staging en dbt (8 modelos)
- [x] Modelo dimensional (marts)
- [x] Tests de calidad de datos (38 tests)
- [x] Automatización con GitHub Actions
- [ ] Dashboard
- [ ] Diagrama de arquitectura

## Autor

**Luis Enrique Allcca Alarcón** — Data Analyst | Data Engineering  
[LinkedIn](https://www.linkedin.com/in/linkedin.com/in/luis-enrique-allcca-alarcon) · [GitHub](https://github.com/LuisEnrique98)

## Licencia

Código bajo licencia [MIT](LICENSE). Dataset bajo [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).
