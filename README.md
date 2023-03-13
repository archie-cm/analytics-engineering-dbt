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
