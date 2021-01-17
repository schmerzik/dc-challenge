{{ config(alias='product_model') }}

select
  Id, EAN, Price
from source.products