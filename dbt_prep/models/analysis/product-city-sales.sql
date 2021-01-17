with
  ordr as ( select * from {{ ref('order') }} ),
  c as ( select * from {{ ref('customer') }} ),
  p as ( select * from {{ ref('product') }} )

select p.Id as ProductId, p.EAN, o.City, o.TotalQuantity, (o.TotalQuantity * p.Price) as Turnover
from (
  select ordr.ProductId, SUM(ordr.Quantity) as TotalQuantity, c.City
  from ordr
  left join c on (ordr.CustomerId = c.Id)
  group by ordr.ProductId, c.City) o
left join p on (o.ProductId = p.Id)