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
Following features get created in the table ```RUDDER_USER_ECOMMERCE_FEATURES``` in the schema specified in pb connection (in step 2 above)


## Working features
    - last_transaction_value (float): The total value of products that are part of the last transaction.
    - avg_transaction_value (float): Total price in each transaction/Total number of transactions.
    - avg_units_per_transaction (float): It shows the average units purchased in each transaction. (Total units in each transaction/Total transactions). Includes only those transactions where the total price (from column current_total_price) is greater than zero. So, the feature exclude transactions with 100% off, replacement products etc that may result in the total_price being equal to zero.
    - median_transaction_value (float) : Median value of total price of all the transactions
    - highest_transaction_value (float) : Of all the transactions done by the user, this features contains the highest transaction value.
    - days_since_last_purchase (int): Number of days since the user purchased the latest product
    - transactions_in_past_n_days (int) : Number of transactions in last n days from today. N is defined by us.
    - total_transactions (int) : Total number of transactions done by the user
    - has_credit_card (bool): If the user has a credit card.
    - days_since_first_purchase (int): Number of days since the user purchased the first product
    - gross_amt_spent_in_past (float); (overall and in past n days) : Total value of products purchased till date.
    - items_purchased_ever (List of unique product items, List[str]); The list of unique products bought by the user. Max size is controlled from variable var_max_list_size; IF a user has more than this number, such users get null result. If this number is too large, it can create performance issues.

    - carts_in_past_n_days :A cart id is created for events such as create_cart,update_cart. This coln specifies how many cart ids were created in the past n days. N is defined by the user.
    - total_carts: Total carts created by the user till date.
    - products_added_in_past_n_days (both purchased and not purchased): Number of products added by the user in last n days(n is defined by the user)
    - total_products_added (Array[str]): Total products added till date. (array with list of all product ids)
    - days_since_last_cart_add (int) : Number of days since the user has added a product to cart
        
