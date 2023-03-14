{{

config(
    materialized='table',
    unique_key='taxi_id'
)
}}

SELECT
  taxi_id,
  taxi_company,
  taxi_model,
  taxi_type
FROM (
  SELECT
    taxi_id,
    MAX(taxi_make_model) AS taxi_make_model,
    MAX(taxi_company) AS taxi_company,
    MAX(taxi_type) AS taxi_type
  FROM
    `bigquery-public-data.chicago_taxi_trips.taxi_trips`
  WHERE
    taxi_make_model IS NOT NULL
  GROUP BY
    taxi_id
)
