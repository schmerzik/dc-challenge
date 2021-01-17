with
  ordr as ( select * from {{ ref('order') }} ),
  c as ( select * from {{ ref('customer') }} ),
  p as ( select * from {{ ref('product') }} )

select o.TotalPrice, o.CustomerId, o.Datetime, c.Email, c.City
from (
  select ordr.OrderId, SUM(ordr.Quantity * p.Price) as TotalPrice, ordr.CustomerId, ordr.Datetime
  from ordr
  left join p on (ordr.ProductId = p.Id)
  group by ordr.OrderId, ordr.CustomerId, ordr.Datetime) o
left join c on (o.CustomerId = c.Id)