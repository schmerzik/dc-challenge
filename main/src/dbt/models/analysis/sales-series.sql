with
  ordr as ( select * from {{ ref('order') }} ),
  p as ( select * from  {{ ref('product') }} )
select SUM(o.TotalPrice) as Turnover, o.SalesDate, CONCAT(EXTRACT(YEAR FROM o.SalesDate),'-',EXTRACT(WEEK FROM o.SalesDate)) as SalesWeek
from (
  select SUM(ordr.Quantity * p.Price) as TotalPrice, EXTRACT(DATE FROM MAX(ordr.Datetime)) as SalesDate
  from ordr
  left join p on (ordr.ProductId = p.Id)
  group by ordr.OrderId, ordr.CustomerId) o
group by o.SalesDate
order by o.SalesDate asc

/*
create or replace model source.`predict-sales-1`
OPTIONS(MODEL_TYPE = 'ARIMA',TIME_SERIES_TIMESTAMP_COL = 'SalesDate', TIME_SERIES_DATA_COL= 'Turnover', HORIZON = 30, AUTO_ARIMA = TRUE)
as select Turnover, SalesDate from source.`sales-series`;
*/