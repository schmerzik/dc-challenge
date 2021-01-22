{{ config(alias='order_model_test_af') }}

select
  OrderId, CustomerId, ProductId, Quantity, Datetime
from source.orders_test_af