-- time_dimension.sql
{{

config(
    materialized='table',
    unique_key='time_id'
)
}}

WITH time_data AS (
  SELECT
    DISTINCT
    EXTRACT(DATE FROM trip_start_timestamp) AS trip_date,
    EXTRACT(HOUR FROM trip_start_timestamp) AS trip_hour,
    EXTRACT(DAYOFWEEK FROM trip_start_timestamp) AS day_of_week,
    EXTRACT(MONTH FROM trip_start_timestamp) AS month,
    EXTRACT(YEAR FROM trip_start_timestamp) AS year
  FROM
    `{{ ref('taxi_trips_fact') }}`
)

SELECT
  ROW_NUMBER() OVER() AS time_id,
  trip_date,
  trip_hour,
  day_of_week,
  month,
  year
FROM
  time_data
