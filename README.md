# dbt Dimensional Modelling

This is my dbt project about data transform implementation of star schema modeling concepts using the Kimball methodology

![dbt](https://user-images.githubusercontent.com/85284506/206355084-5b303c9e-7a7b-4e12-91e0-ca6a43416ca3.jpg)

dbt (data build tool) is a data `transformation` tool that uses select `SQL` statements. to deploy analytics code following `software engineering` best practices.

## Project Features

### Sources
```
version: 2

sources:
    - name: staging
      tables:
        - name: yellowtrip_data

models:
  - name: stg_table
    description: staging layer for yellowtrip data warehouses
```
```sql
{{ config(materialized='view') }}

select
    {{ dbt_utils.surrogate_key(['unique_key']) }} as tripid,
    *
from {{ source('staging','yellowtrip_data') }}
```
### References
```sql
select distinct
    payment_type,
from {{ ref('stg_table') }}
```
Models must use `source` and `ref`  for lineage to be accessible

### Descriptions
A user-defined `description`. Can be used to document a model, sources, seeds, snapshot, analyses, and macros. Allowing for a detailed definition.
```
models:
  - name: taxi_trip_fact
    description: "fact table"
    columns:
      - name: tripid
        description: "Fact table primary key" 
```        

## Fact Table
The fact table is the table that contains the measures or metrics we want to analyze. In this case, the taxi_trips table contains the details about the trips, so we can use it as the fact table.

## Dimension Tables
The dimension tables contain the descriptive attributes that provide context to the fact table. In this case, we can identify the following dimension tables:

- dim_time: This table contains information about the date and time of the trip, such as the day of the week, the hour of the day, and the month.
```
WITH time_data AS (
  SELECT
    DISTINCT
    EXTRACT(DATE FROM trip_start_timestamp) AS trip_date,
    EXTRACT(HOUR FROM trip_start_timestamp) AS trip_hour,
    EXTRACT(DAYOFWEEK FROM trip_start_timestamp) AS day_of_week,
    EXTRACT(MONTH FROM trip_start_timestamp) AS month,
    EXTRACT(YEAR FROM trip_start_timestamp) AS year
  FROM
    {{ ref('stg_table') }}
)

SELECT
  trip_date,
  trip_hour,
  day_of_week,
  month,
  year
FROM
  time_data
```

- dim_location: This table contains information about the pickup and dropoff locations of the trip, such as the neighborhood, the community area, and the latitude and longitude coordinates.
```
WITH cte as (
select
  distinct
  pickup_census_tract as location_id,
  pickup_community_area as community_area,
  pickup_latitude as latitude,
  pickup_longitude as longitude
from
  {{ ref('stg_table') }}

union distinct

select
  distinct
  dropoff_census_tract as location_id,
  dropoff_community_area as community_area,
  dropoff_latitude as latitude,
  dropoff_longitude as longitude
from
  {{ ref('stg_table') }}
)

SELECT * FROM cte WHERE location_id is NOT NULL
```

- dim_taxi: This table contains information about the taxi, such as the taxi ID, the taxi company, and the taxi type.
```
SELECT
  taxi_id,
  company
FROM 
    {{ ref('stg_table') }}
```

- dim_payment: This table contains information about the payment method, such as the payment type and the tip amount.
```
SELECT
  payment_type,
  tips
FROM (
  SELECT
    payment_type,
    AVG(tips) AS tips
  FROM
    {{ ref('stg_table') }}
  GROUP BY
    payment_type
)
WHERE payment_type IS NOT NULL
```


## Dimensional Model
With the fact and dimension tables identified, we can create the following dimensional model:

### fact_taxi_trips Table
This table contains the measures or metrics we want to analyze, such as the trip distance, the trip time, and the fare amount.

Column | Name	Data | Type	| Description
| --- | --- | --- | --- |
trip_id	| STRING |	Unique | identifier for each trip
pickup_location_id	| INTEGER	| Foreign key | to the dim_location table for the pickup location
dropoff_location_id	| INTEGER	| Foreign key | to the dim_location table for the dropoff location
taxi_id	| INTEGER	| Foreign key | to the dim_taxi table for the taxi
payment_id	| INTEGER	| Foreign key | to the dim_payment table for the payment method
trip_start_timestamp	| TIMESTAMP	| | Start time of the trip
trip_end_timestamp	| TIMESTAMP | | End time of the trip
trip_seconds	| INTEGER	| | Trip duration in seconds
trip_miles	| FLOAT | 	| Trip distance in miles
fare	| FLOAT	| | Total fare amount
tips	| FLOAT	| | Total tip amount
tolls	| FLOAT	| | Total tolls amount
extras	| FLOAT	| | Total extras amount
trip_total	| FLOAT	| | Total trip amount

### dim_location Table
This table contains information about the pickup and dropoff locations of the trip.

Column | Name	| Data Type	| Description
| --- | --- | --- | --- |
location_id	| INTEGER	| Unique | identifier for each location
community_area	| INTEGER	| | Community area number
community_area_name	| STRING | | Community area name
census_tract	| INTEGER | | Census tract number
census_block	| STRING	| | Census block number
latitude	| FLOAT	| | Latitude coordinate of the location
longitude	| FLOAT	| | Longitude coordinate of the location

### dim_time Table
This table contains information about the date and time of the trip.

Column | Name	| Data Type	| Description
| --- | --- | --- | --- |
time_id	| INTEGER	| Unique | identifier for each time
trip_start_timestamp	| TIMESTAMP	| | Start time of the trip
trip_end_timestamp	| TIMESTAMP	| | End time of the trip
year	| INTEGER	| | Year of the trip
quarter | INTEGER	| | Quarter of the year
month	| INTEGER	| | Month of the year
day_of_month	| INTEGER	| | Day of the month
day_of_week	| INTEGER	| | Day of the week (1 = Monday,


### Tests
Testing with singular and generic tests to check every value stored.
  + `not_null`: verify that every value in a column (e.g. payment_id) contains unique values
  + `unique`: check that the values for a given column are always present
  + `accepted values`: validate whether a set of values within a column is present
  + `relationships`: To check referential integrity when having related columns (e.g. payment_id) in two different tables
  
```
  - name: payment_id
    description: "Identifier for payment types"      
    tests:
      - not_null
      - relationships:
          to: ref('dim_payment')
          field: payment_id
              
  - name: dim_payment
    description: "{{ doc('dim_payment') }}"
    columns:
    - name: payment_id
      tests:
        - not_null
        - unique
    columns:
    - name: payment_type_description
      tests:
        - not_null
        - accepted_values:
            values: ['Credit card', 'Cash', 'No charge', 'Dispute', 'Unknown', 'Voided trip']
 ```

### Relevant Commands
- run `dbt run`
- run `dbt test`
- run `dbt docs generate`
- run `dbt docs serve`

## DAG (Lineage)
![image](https://user-images.githubusercontent.com/108534539/225040741-a512dd58-a7d9-42a4-9e32-dc07113d04b8.png)
