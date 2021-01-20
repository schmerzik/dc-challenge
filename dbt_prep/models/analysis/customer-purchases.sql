with purchases as (
    select o.CustomerId, 
        SUM(o.Quantity*p.Price) as TotalPurchasePrice, 
        COUNT(DISTINCT o.OrderId) as PurchaseCount, 
        COUNT(DISTINCT o.ProductId) as ProductCount,
        TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), MAX(o.Datetime), DAY) as DaysSinceLastPurchase
    from source.orders_test o 
    left join source.products p on (p.Id = o.ProductId)
    group by o.CustomerId
)
select
  c.Id, c.Email, c.Gender, c.PostalCode, c.City,
  p.TotalPurchasePrice, p.PurchaseCount, p.ProductCount, p.DaysSinceLastPurchase
from source.customers_1 c
left join purchases p on (p.CustomerId = c.Id);

/*
TODO: REMOVE OLD REFERENCE QUERIES

KMEANS TRAINING:
create or replace model source.cust_cluster_4
transform(
    ML.Quantile_bucketize(TotalPurchasePrice,8) over() as TotalPurchasePrice_b,
    ML.Quantile_bucketize(ProductCount,8) over() as ProductCount_b,
    ML.Quantile_bucketize(PurchaseCount,8) over() as PurchaseCount_b,
    ML.Quantile_bucketize(DaysSinceLastPurchase,8) over() as DaysSinceLastPurchase_b,
    Gender)
options(model_type='kmeans',early_stop=true,max_iterations=8,NUM_CLUSTERS=4,KMEANS_INIT_METHOD='RANDOM')
as (select * from source.`customer-purchases-4`cp );

create or replace model source.cust_cluster_5
transform(
    TotalPurchasePrice,
    ProductCount,
    PurchaseCount,
    DaysSinceLastPurchase,
    Gender)
options(model_type='kmeans',early_stop=true,max_iterations=8,NUM_CLUSTERS=4,KMEANS_INIT_METHOD='RANDOM')
as (select * from source.`customer-purchases-4`cp );

SQL:

with
  purchases as (
    select o.CustomerId, SUM(o.Quantity*p.Price) as TotalPurchasePrice, COUNT(DISTINCT o.OrderId) as PurchaseCount, COUNT(DISTINCT o.ProductId) as ProductCount
    from source.orders_test o 
    left join source.products p on (p.Id = o.ProductId)
    group by o.CustomerId
  )
select c.Id, c.Email, c.Gender, c.PostalCode,
        p.TotalPurchasePrice, p.PurchaseCount, p.ProductCount
from source.customers_1 c
left join purchases p on (p.CustomerId = c.Id);


create or replace table source.`customer-purchases-3` as (
with customerPurchases as (
    select o.CustomerId, p.EAN, SUM(o.Quantity) as productQuantity
            from source.orders_test o
            left join source.products p on (p.Id = o.ProductId)
            group by o.CustomerId, p.EAN
),
purchases as (
    select o.CustomerId, SUM(o.Quantity*p.Price) as TotalPurchasePrice, COUNT(DISTINCT o.OrderId) as PurchaseCount, COUNT(DISTINCT o.ProductId) as ProductCount
    from source.orders_test o 
    left join source.products p on (p.Id = o.ProductId)
    group by o.CustomerId
)
select
  c.Id, c.Email, c.Gender, c.PostalCode, c.City,
  p.TotalPurchasePrice, p.PurchaseCount, p.ProductCount,
  t1.CustomerId, t2.EAN as FavoriteProduct, 
from (
    select CustomerId, MAX(productQuantity) as maxPQ
    from customerPurchases
    group by CustomerId
) t1
left join customerPurchases t2 on (t1.CustomerId = t2.CustomerId and t1.maxPQ = t2.productQuantity)
left join source.customers_1 c on (c.Id = t1.CustomerId)
left join purchases p on (p.CustomerId = c.Id));


create or replace table source.`customer-purchases-4` as (
with purchases as (
    select o.CustomerId, 
        SUM(o.Quantity*p.Price) as TotalPurchasePrice, 
        COUNT(DISTINCT o.OrderId) as PurchaseCount, 
        COUNT(DISTINCT o.ProductId) as ProductCount,
        TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), MAX(o.Datetime), DAY) as DaysSinceLastPurchase
    from source.orders_test o 
    left join source.products p on (p.Id = o.ProductId)
    group by o.CustomerId
)
select
  c.Id, c.Email, c.Gender, c.PostalCode, c.City,
  p.TotalPurchasePrice, p.PurchaseCount, p.ProductCount, p.DaysSinceLastPurchase
from source.customers_1 c
left join purchases p on (p.CustomerId = c.Id));*/