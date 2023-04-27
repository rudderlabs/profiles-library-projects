SELECT iv.invoices_id,
       ch.created as charges_created_timestamp ,
       sc.canceled_at,
       iv.amount_due,
       iv.customer,
       to_timestamp(iv.created) as invoice_created_timestamp,
       sc.subscriptions_id, 
       sc.plan_id,
       pl.amount as plan_amount,
       rf.amount as refund_amount,
       concat(pl.interval,pl.interval_count) as plan_interval,
       ch.amount as charges_amount
FROM (SELECT *
   FROM
     (SELECT *,
             row_number() OVER (PARTITION BY INVOICES_ID
                                ORDER BY timestamp DESC) AS row_num
      FROM ANALYTICS_DB.DATA_APPS_SIMULATED_STRIPE.STRIPE_INVOICES) X
   WHERE row_num = 1) iv
LEFT JOIN
  (SELECT *
   FROM
     (SELECT customer,
             subscriptions_id,
             plan_id,
             max(canceled_at) over(PARTITION BY subscriptions_id) AS canceled_at,
             row_number() OVER (PARTITION BY subscriptions_id
                                ORDER BY timestamp DESC) AS row_num
      FROM ANALYTICS_DB.DATA_APPS_SIMULATED_STRIPE.STRIPE_SUBSCRIPTIONS) X
   WHERE row_num = 1) sc ON iv.subscription = sc.subscriptions_id
LEFT JOIN (select * from ANALYTICS_DB.DATA_APPS_SIMULATED_STRIPE.STRIPE_CHARGES where captured = true) ch ON iv.invoices_id = ch.invoice
LEFT JOIN ANALYTICS_DB.DATA_APPS_SIMULATED_STRIPE.stripe_refunds rf on rf.charge = ch.charges_id
left join (SELECT *
   FROM
     (SELECT *,
             row_number() OVER (PARTITION BY PLANS_ID
                                ORDER BY timestamp DESC) AS row_num
      FROM ANALYTICS_DB.DATA_APPS_SIMULATED_STRIPE.STRIPE_PLANS ) X
   WHERE row_num = 1) pl on sc.plan_id = pl.plans_id