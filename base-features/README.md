# About

This is PB repo to create user features from event stream tables created using Rudderstack SDK


## How to Use

After installing PB and configuring your connections profile, you need to change inputs.yaml with names of your source tables. Once that is done, please mention their names as edge_sources in profiles.yaml and define specs for creating ID stitcher / feature table. 

Use this command to validate that your project shall be able to access the warehouse specified in connections profile and create material objects there.

```shell script
pb validate access
```

You can use this command to generate SQL, which will also tell you in case there are syntax errors in your model YAML file.

```shell script
pb compile
```

If there are no errors, use this command to create the output table on the warehouse.

```shell script
pb run
```

## SQL queries for data analysis.

Let's assume that the materialized table created by PB was named MATERIAL_USER_STITCHING_26f16d24_29 , inside schema RUDDER_360 of database RUDDER_EVENTS_PRODUCTION. The materialized table name will change with each run, the view USER_STITCHING will point to the most recently created one.

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
See <a href="https://rudderlabs.github.io/pywht">public docs</a> for more information on using PB.



1. Install Profiles tool, from the link above
2. Setup connection to your warehouse, following the instructions from the documentation
3. cd to this directory where the git repo is cloned
4. Do ```pb run```
Following features get created in the table ```rudder_user_base_features``` in the schema specified in pb connection (in step 2 above)


## Working features
        - days_since_last_seen(int): Derived from pages and tracks
        - is_churned_7_days(bool): It specifies if there is any activity observed in the last n days. It is dependent on days_since_last_seen.)
        - days_since_account_creation(int)
        - has_mobile_app(bool)
        - campaign_sources(Array[str])
        - is_active_on_website(bool)
        - device_manufacturer(str)
        - active_days_in_past_7_days(int): Derived from both pages and tracks tables.
        - active_days_in_past_365_days(int): Derived from both pages and tracks tables.
        - total_sessions_till_date(int)
        - total_sessions_last_week(int)
        - avg_session_length_in_sec_overall(float)
        - avg_session_length_in_sec_last_week(float)
        - first_seen_date(str): The first date on which an event has been recorded by the user
        - last_seen_date(str): The latest date on which an event has been recorded by the user
        - avg_session_length_in_sec_365_days(float)
        - total_sessions_90_days(int)
        - total_sessions_365_days(int)
        - first_campaign_name(str)
        - last_campaign_name(str)
        - first_source_name(str)
        - last_source_name(str)
        - campaigns_list(Array[str])
        - mediums_list(Array[str])
        - sources_list(Array[str])
## The below features are derived from the identify call. If multiple values are found, the most recent value is used.
        - state(Str)
        - country(Str)
        - first_name(str)
        - last_name(Str)
        - currency(str)
        - device_type(str)
        - device_name(str)


        
