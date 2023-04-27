# About

This is PB repo to create user features from Shopify event stream tables created using Rudderstack SDK


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

Following features get created in the table ```shopify_user_features``` in the schema specified in pb connection 


## Working features
        - days_since_last_seen(int): Derived from pages and tracks
        - is_churned_7_days(bool): It specifies if there is any activity observed in the last n days. It is dependent on days_since_last_seen.)
        - days_since_last_cart_add(int): Number of days since the user has added a product to cart
        - total_refund(float): Total refund for a particular user till date. Derived from Ordercancelled table)
        - refund_count(int): Total number of times an order has been cancelled by a user and has been refunded(Derived from ordercancelled table)
        - days_since_last_purchase(int): Number of days since the user purchased the latest product(Derived from OrderCreated)
        - days_since_first_purchase(int): Number of days since the user purchased the first product(Derived from OrderCreated)
        - has_credit_card(bool) 
        - avg_units_per_transaction(float): It shows the average units purchased in each transaction. (Total units in each transaction/Total transactions). Includes only those transactions where the total price (from column current_total_price) is greater than zero. So, the feature exclude transactions with 100% off, replacement products etc that may result in the total_price being equal to zero.(Derived from rsOrderCreated)
        - avg_transaction_value(float): Total price in each transaction/Total number of transactions.(Derived from rsOrderCreated)
        - highest_transaction_value(float): Of all the transactions done by the user, this features contains the highest transaction value.
        - median_transaction_value(float): Median value of total price of all the transactions 
        - total_transactions(int): Total number of transactions done by the user
        - total_refund_in_past_1_days(float): Total refund for a particular user in last 1 day
        - total_refund_in_past_7_days(float): Total refund for a particular user in last 7 day
        - days_since_account_creation(int)
        - has_mobile_app(bool)
        
        - campaign_sources(Array[str])
        - is_active_on_website(bool)
        - device_manufacturer(str)
        - active_days_in_past_7_days(int): Derived from both pages and tracks tables.

        - active_days_in_past_365_days(int): Derived from both pages and tracks tables.
        - total_sessions_till_date(int)
        - total_sessions_last_week(int)
        - avg_session_length_in_sec_overall9(float)
        - avg_session_length_in_sec_last_week(float)
        - first_seen_date(str): The first date on which an event has been recorded by the user
        - last_seen_date(str): The latest date on which an event has been recorded by the user
        - carts_in_past_1_days(int): A cart id is created for events such as create_cart,update_cart. This coln specifies how many cart ids were created in the past 1 days(Derived from cart_create and cart_update events)
        - carts_in_past_7_days(int): A cart id is created for events such as create_cart,update_cart. This coln specifies how many cart ids were created in the past 7 days(Derived from cart_create and cart_update events)
        - carts_in_past_365_days(int):
        A cart id is created for events such as create_cart,update_cart. This coln specifies how many cart ids were created in the past 365 days(Derived from cart_create and cart_update events)
        - total_carts(int): Total carts created by the user till date. (Derived from cart_create and cart_update events)
        - last_transaction_value(float)
        - total_products_added(Array[str]):: Total products added till date. (array with list of all product ids)
        - products_added_in_past_1_days(Array[str]): Products added by the user in last 1 days(Derived from cart_create and cart_update events. Disclaimer: If a product is added to the cart but removed later, such products won't be part of this list.)
        - products_added_in_past_7_days(Array[str]): Products added by the user in last 7 days
        - products_added_in_past_365_days(Array[str]): Products added by the user in last 365 days
        - avg_session_length_1_days(float)
        - avg_session_length_365_days(float)
        - total_sessions_1_days(int)
        - total_sessions_90_days(int)
        - total_sessions_365_days(int)
        - last_cart_status(bool): Derived from joining ORDER_CREATED and ORDER_CANCELLED table
        - last_cart_value_in_dollars(float) (does not consider if products are removed)
        - transactions_in_past_1_days(int)
        - transactions_in_past_90_days(int)
        - transactions_in_past_365_days(int)
        - net_amt_spent_in_past_1_days(float) : (Sales-Refund) Derived from joining ORDER_CREATED and ORDER_CANCELLED table
        - net_amt_spent_in_past_90_days(float) : (Sales-Refund) Derived from joining ORDER_CREATED and ORDER_CANCELLED table
        - net_amt_spent_in_past_365_days(float) : (Sales-Refund)Derived from joining ORDER_CREATED and ORDER_CANCELLED table
        - net_amt_spent_in_past(float) : Derived from joining ORDER_CREATED and ORDER_CANCELLED table
        - gross_amt_spent_in_past(float) :Consider only sales. Derived from joining ORDER_CREATED and ORDER_CANCELLED table

## The below features are derived from the identify call. If multiple values are found, the most recent value is used.
        - state(Str)
        - country(Str)
        - first_name(str)
        - last_name(Str)
        - currency(str)
        - device_type(str)
        - device_name(str)
## SQL queries for data analysis.

Let's assume that the materialized table created by PB was named MATERIAL_shopify_user_id_stitcher_26f16d24_29 , inside schema RUDDER_360 of database RUDDER_EVENTS_PRODUCTION. The materialized table name will change with each run, the view shopify_user_id_stitcher will point to the most recently created one.

Total number of records:
```sql
select count(*) from RUDDER_EVENTS_PRODUCTION.RUDDER_360.shopify_user_id_stitcher;
```

Total number of distinct records (main_id):
```sql
select count(distinct main_id) from RUDDER_EVENTS_PRODUCTION.RUDDER_360.shopify_user_id_stitcher;
```

Max mappings to a single canonical ID:
```sql
select main_id, count(other_id) as "CNT"
from RUDDER_EVENTS_PRODUCTION.RUDDER_360.shopify_user_id_stitcher
group by main_id
order by CNT DESC;
```

Say there was a canonical ID '0013d4fa-fdf7-5736-85d1-063378251398' that had more than 1000 mappings. So to check more on other ID types and their count:
```sql
select count (distinct other_id) as "OTHER_ID_COUNT", other_id_type from RUDDER_EVENTS_PRODUCTION.RUDDER_360.shopify_user_id_stitcher
where main_id = '0013d4fa-fdf7-5736-85d1-063378251398'
group by other_id_type;
```

## Know More

Contact RudderStack team to know more details about Profiles. 
