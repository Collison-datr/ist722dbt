with stg_orders as 
(
    select
        OrderID,  
        {{ dbt_utils.generate_surrogate_key(['employeeid']) }} as employeekey, 
        {{ dbt_utils.generate_surrogate_key(['customerid']) }} as customerkey, 
        replace(to_date(orderdate)::varchar,'-','')::int as orderdatekey
    from {{source('northwind','Orders')}}
),
stg_order_details as
(
    select 
        orderid,
        sum(Quantity) as quantityonorder, 
        sum(Quantity*UnitPrice*(1-Discount)) as totalorderamount
    from {{source('northwind','Order_Details')}}
    group by orderid
),

stg_products as (
    select * from {{ source('northwind','Products')}}
)
select  {{ dbt_utils.generate_surrogate_key(['stg_products.productid']) }} as productkey, 
    stg_products.* 
from stg_products
