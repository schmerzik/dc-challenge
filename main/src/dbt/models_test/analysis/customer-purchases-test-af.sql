with purchases as (
    select o.CustomerId, 
        SUM(o.Quantity*p.Price) as TotalPurchasePrice, 
        COUNT(DISTINCT o.OrderId) as PurchaseCount, 
        COUNT(DISTINCT o.ProductId) as ProductCount,
        TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), MAX(o.Datetime), DAY) as DaysSinceLastPurchase
    from source.orders_test_af o 
    left join source.products p on (p.Id = o.ProductId)
    group by o.CustomerId
)
select
  c.Id, c.Email, c.Gender, c.PostalCode, c.City,
  p.TotalPurchasePrice, p.PurchaseCount, p.ProductCount, p.DaysSinceLastPurchase
from source.customers_test_af c
left join purchases p on (p.CustomerId = c.Id)
