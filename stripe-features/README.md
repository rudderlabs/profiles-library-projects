# RS360

## How to Use

After installing RS360 and configuring your connections profile, you need to change inputs.yaml with names of your source tables. Once that is done, please mention their names as inputs in models.yaml and define specs for creating ID stitcher / feature table. 

You can use this command to generate SQL, which will also tell you in case there are syntax errors in your model YAML file.

```shell script
wht compile
```

If there are no errors, use this command to create the output table on the warehouse.

```shell script
wht run
```

## SQL queries for data analysis.

Let's assume that the materialized table created by RS360 was named MATERIAL_USER_STITCHING_26f16d24_29 , inside schema RUDDER_360 of database RUDDER_EVENTS_PRODUCTION. The materialized table name will change with each run, the view USER_STITCHING will point to the most recently created one.

Total number of records:
```sql
select count(*) from RUDDER_EVENTS_PRODUCTION.RUDDER_360.USER_STITCHING;
```

Total number of distinct records (main_id):
```sql
select count(distinct main_id) from RUDDER_EVENTS_PRODUCTION.RUDDER_360.USER_STITCHING;
```

Max mappings to a single canonical ID:
```sql
select main_id, count(other_id) as "CNT"
from RUDDER_EVENTS_PRODUCTION.RUDDER_360.USER_STITCHING
group by main_id
order by CNT DESC;
```

Say there was a canonical ID '0013d4fa-fdf7-5736-85d1-063378251398' that had more than 1000 mappings. So to check more on other ID types and their count:
```sql
select count (distinct other_id) as "OTHER_ID_COUNT", other_id_type from RUDDER_EVENTS_PRODUCTION.RUDDER_360.USER_STITCHING
where main_id = '0013d4fa-fdf7-5736-85d1-063378251398'
group by other_id_type;
```

## Know More
See <a href="https://rudderlabs.github.io/pywht">public docs</a> for more information on using RS360.

## views 
stripeInvoicesView.sql added in views folder. we are using this view as input for subscription based features.
