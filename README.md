# dbt Dimensional Modelling

This is my dbt project about data transform implementation of star schema modeling concepts using the Kimball methodology

![dbt](https://user-images.githubusercontent.com/85284506/206355084-5b303c9e-7a7b-4e12-91e0-ca6a43416ca3.jpg)

dbt (data build tool) is a data `transformation` tool that uses select `SQL` statements. to deploy analytics code following `software engineering` best practices.

## Project Features

### Sources
```
sources:
    - name: staginglayer
      database: datafellowship-370013
      schema: rawdata
      tables:
        - name: yellowtrip_data
```
```sql
select
    {{ dbt_utils.surrogate_key(['vendorid', 'tpep_pickup_datetime']) }} as tripid,
    *
from {{ source('staginglayer','yellowtrip_data') }}
```
### References
```sql
select distinct
    payment_type as payment_id,
from {{ ref('stg_trip') }}
```
Models must use `source` and `ref`  for lineage to be accessible

### Descriptions
A user-defined `description`. Can be used to document a model, sources, seeds, snapshot, analyses, and macros. Allowing for a detailed definition.
```
models:
  - name: fact_trip
    description: "{{ doc('fact_trip') }}" #reference docs block
    columns:
      - name: tripid
        description: "Fact table primary key" #standard description
```        
You can store `descriptions` in a markdown file and reference with {{ doc('fact_trip') }}, which references this markdown file:
```
{% docs fact_trip %}
The yellow taxi trip records include fields capturing pick-up and drop-off dates/times, pick-up and drop-off locations, trip distances, itemized fares, rate types, payment types, and driver-reported passenger counts. The data used in the attached datasets were collected and provided to the NYC Taxi and Limousine Commission (TLC) by technology providers authorized under the Taxicab & Livery Passenger Enhancement Programs (TPEP/LPEP).
{% enddocs %}
```
## Fact Table
The fact table is the table that contains the measures or metrics we want to analyze. In this case, the taxi_trips table contains the details about the trips, so we can use it as the fact table.

## Dimension Tables
The dimension tables contain the descriptive attributes that provide context to the fact table. In this case, we can identify the following dimension tables:

- dim_time: This table contains information about the date and time of the trip, such as the day of the week, the hour of the day, and the month.
- dim_location: This table contains information about the pickup and dropoff locations of the trip, such as the neighborhood, the community area, and the latitude and longitude coordinates.
- dim_taxi: This table contains information about the taxi, such as the taxi ID, the taxi company, and the taxi type.
- dim_payment: This table contains information about the payment method, such as the payment type and the tip amount.

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

### Jinja & Macros
Macros in Jinja are pieces of code that can be reused multiple times – they are analogous to `functions` in other programming languages
```
 {#
    This macro returns the description of the payment_type 
#}

{% macro payment_type(payment_type) -%}

    case {{ payment_type }}
        when 1 then 'Credit card'
        when 2 then 'Cash'
        when 3 then 'No charge'
        when 4 then 'Dispute'
        when 5 then 'Unknown'
        when 6 then 'Voided trip'
    end

{%- endmacro %}
```
```sql
select distinct
    payment_type as payment_id,
    {{ payment_type('payment_type') }} as payment_type_description
```

### Relevant Commands
- run `dbt run`
- run `dbt test`
- run `dbt docs generate`
- run `dbt docs serve`

## DAG (Lineage)
![image](https://user-images.githubusercontent.com/85284506/206355285-be2ed9ad-21ce-40c2-a0b0-3e3f5ef532ba.png)
