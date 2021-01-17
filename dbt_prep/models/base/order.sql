{{ config(alias='order_model') }}

select
  OrderId, CustomerId, ProductId, Quantity, Datetime
from source.test_orders