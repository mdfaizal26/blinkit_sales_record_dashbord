create table salesrecord(
OrderID text primary key,
OrderDate date,
CustomerID text,
City varchar(50),
Category varchar(50),
Product varchar(50),
Quantity int,
UnitPrice numeric(10,2),
TotalAmount numeric(12,2),
PaymentMode varchar(50)
);
select * from salesrecord;

----Queries start-----------------

--1) Total Sales per City
    select city, sum(totalamount) as total_sales
	from salesrecord
	group by city;

--2) Total Orders per Payment Mode
    select count(orderid) as total_order, paymentmode
	from salesrecord
	group by paymentmode
	order by total_order desc;
	
--3) Average Order Value (AOV) by City

    select city,
    sum(totalamount)/count(distinct orderid) as AOV
    from salesrecord
    group by city;

--4) Customers by Total Spend.	
   select customerid, sum(totalamount) as Total_Spend
   from salesrecord
   group by customerid
   order by Total_Spend Desc
   limit 5;

--5) Percentage of Orders by Payment Mode
   select paymentmode,
   round(count(distinct orderid)*100.0/
   (select count(distinct orderid)from salesrecord),2)as order_Percent
   from salesrecord
   group by paymentmode;

--6) Highest Selling Category in Each City
   select city, category, totalsales
   from (
     select city, category,
	 sum(totalamount) as totalsales,
	 rank() over(partition by city order by sum(totalamount) desc)as rk
	 from salesrecord
	 group by city, category
   )t
   where rk = 1;

--7) Average Quantity per Order by Category
   select category,
    avg(quantity)as avg_Quantity
	from salesrecord
	group by category;

--8) Cities with Sales Higher than Overall Average
   with avg_sales as (
   select avg(totalamount) as overall_avg
   from salesrecord
   )
   select city, sum(totalamount)as city_sales
   from salesrecord, avg_sales
   group by city, overall_avg
   having sum(totalamount)>overall_avg;

--9) Orders having more than 5 unique products
    select orderid, count(distinct category) as product_types
	from salesrecord
	group by orderid
	having count(distinct category)>5;

--10)Sales Share of Top 20% Customers
    with cust_sales as (
   select customerid,
   sum(totalamount) as totalsales
   from salesrecord
   group by customerid
	),
	ranked as (
select customerid, totalsales,
  sum(totalsales) over(order by totalsales desc) as running_sales,
  sum(totalsales) over() as all_sales
  from cust_sales
  
	)
   select count(*) as top_customers,
   round(sum(totalsales)*100.0/max(all_sales),2) as sales_percent
   from ranked
   where running_sales<= 0.2*all_sales;

--11) City wise total orders & total sales 
   select city,
   count(distinct orderid) as total_ordeers,
   sum(totalamount) as total_sales
   from salesrecord
   group by city
   order by total_sales desc;

--12) Category wise average unit price
    select category,
	round(avg(unitprice),2) as avg_unitprice
	from salesrecord
	group by category
	order by avg_unitprice desc;

--13) Customers who bought more than 500 units total.
    select customerid,
	sum(quantity) as total_quantity
	from salesrecord
	group by customerid
	having sum(quantity)>500
	order by total_quantity desc;

--14) Payment mode wise average order value
    select paymentmode,
	round(sum(totalamount)/count(distinct orderid),2) as avg_order_value
	from salesrecord
	group by paymentmode
	order by avg_order_value desc;


--15) Yearly sales trend (total sales per year)
    select  extract(year from orderdate) as Order_Year,
    sum(totalamount)  as Yearly_Sales
    from salesrecord
   group  by extract(year from orderdate)
   order by Order_Year;





