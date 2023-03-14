{{
  config(
    materialized='table',
    unique_key='trip_id'
  )
}}

select
  trip_id,
  pickup_location_id,
  dropoff_location_id,
  taxi_id,
  payment_id,
  trip_start_timestamp,
  trip_end_timestamp,
  trip_seconds,
  trip_miles,
  fare,
  tips,
  tolls,
  extras,
  trip_total
from
  `bigquery-public-data.chicago_taxi_trips.taxi_trips`
