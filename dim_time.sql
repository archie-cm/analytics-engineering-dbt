{{
  config(
    materialized='table',
    unique_key='time_id'
  )
}}

select
  trip_start_timestamp,
  extract(year from trip_start_timestamp) as year,
  extract(quarter from trip_start_timestamp) as quarter,
  extract(month from trip_start_timestamp) as month,
  extract(day from trip_start_timestamp) as day_of_month,
  extract(dayofweek from trip_start_timestamp) as day_of_week,
  extract(hour from trip_start_timestamp) as hour
from
  `bigquery-public-data.chicago_taxi_trips.taxi_trips`
