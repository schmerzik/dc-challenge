with purchases as (
    select o.CustomerId, 
        SUM(o.Quantity*p.Price) as TotalPurchasePrice, 
        COUNT(DISTINCT o.OrderId) as PurchaseCount, 
        COUNT(DISTINCT o.ProductId) as ProductCount,
        TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), MAX(o.Datetime), DAY) as DaysSinceLastPurchase
    from source.orders o 
    left join source.products p on (p.Id = o.ProductId)
    group by o.CustomerId
)
select
  c.Id, c.Email, c.Gender, c.PostalCode, c.City,
  p.TotalPurchasePrice, p.PurchaseCount, p.ProductCount, p.DaysSinceLastPurchase
from source.customers c
left join purchases p on (p.CustomerId = c.Id)

/*
K_MEANS CLUSTER MODEL (bucketized - log to account for the right-tailed data distribution):
create or replace model source.cust_cluster_buck
transform(
    ML.Quantile_bucketize(sqrt(TotalPurchasePrice),8) over() as TotalPurchasePrice_b,
    ML.Quantile_bucketize(sqrt(ProductCount),8) over() as ProductCount_b,
    ML.Quantile_bucketize(sqrt(PurchaseCount),8) over() as PurchaseCount_b,
    ML.Quantile_bucketize((DaysSinceLastPurchase - 388),8) over() as DaysSinceLastPurchase,
    Gender)
options(model_type='kmeans',early_stop=true,max_iterations=5,num_clusters=5,KMEANS_INIT_METHOD='RANDOM')
as (select * from source.`customer-purchases`cp );

K_MEANS CLUSTER MODEL (unbucketized):
create or replace model source.cust_cluster
transform(
    TotalPurchasePrice,
    ProductCount,
    PurchaseCount,
    DaysSinceLastPurchase,
    Gender)
options(model_type='kmeans',early_stop=true,max_iterations=5,num_clusters=5,KMEANS_INIT_METHOD='RANDOM')
as (select * from source.`customer-purchases`cp );

K_MEANS CLUSTER MODEL (unbucketized - limited to 1 year --> DaysSinceLastPurchase was calculated from today, so -754 instead of 365):
create or replace model source.cust_cluster_1year
transform(
    TotalPurchasePrice,
    ProductCount,
    PurchaseCount,
    (DaysSinceLastPurchase - 388) as DaysSinceLastPurchase,
    Gender)
options(model_type='kmeans',early_stop=true,max_iterations=5,num_clusters=5,KMEANS_INIT_METHOD='RANDOM')
as (select * from source.`customer-purchases`cp where DaysSinceLastPurchase < 754);

*/