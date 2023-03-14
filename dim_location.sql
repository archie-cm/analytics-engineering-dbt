{{
  config(
    materialized='table',
    unique_key='location_id'
  )
}}

select
  distinct
  pickup_census_tract as census_tract,
  pickup_community_area as community_area,
  pickup_community_area_name as community_area_name,
  pickup_latitude as latitude,
  pickup_longitude as longitude
from
  `bigquery-public-data.chicago_taxi_trips.taxi_trips`

union distinct

select
  distinct
  dropoff_census_tract as census_tract,
  dropoff_community_area as community_area,
  dropoff_community_area_name as community_area_name,
  dropoff_latitude as latitude,
  dropoff_longitude as longitude
from
  `bigquery-public-data.chicago_taxi_trips.taxi_trips`
