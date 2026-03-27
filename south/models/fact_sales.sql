with stg_orders as (
    select
        OrderID,  
        {{ dbt_utils.generate_surrogate_key(['employeeid']) }} as employeekey, 
        {{ dbt_utils.generate_surrogate_key(['customerid']) }} as customerkey, 
        replace(to_date(orderdate)::varchar,'-','')::int as orderdatekey
    from {{ source('northwind','Orders') }}
),

stg_order_details as (
    select 
        orderid,
        sum(Quantity) as quantityonorder, 
        sum(Quantity * UnitPrice * (1 - Discount)) as totalorderamount
    from {{ source('northwind','Order_Details') }}
    group by 1
)

select
    o.OrderID,
    o.employeekey,
    o.customerkey,
    o.orderdatekey,
    od.quantityonorder,
    od.totalorderamount
from stg_orders o
left join stg_order_details od 
    on o.orderid = od.orderid
