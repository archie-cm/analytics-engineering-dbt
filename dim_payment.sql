{{

config(
    materialized='table',
    unique_key='payment_type'
)
}}

SELECT
  payment_type,
  tips
FROM (
  SELECT
    payment_type,
    AVG(tips) AS tips
  FROM
    `bigquery-public-data.chicago_taxi_trips.taxi_trips`
  GROUP BY
    payment_type
)
