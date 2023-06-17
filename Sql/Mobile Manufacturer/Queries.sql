--SQL Advance Case Study

use db_SQLCaseStudies

--Q1--BEGIN 

select distinct State from dim_location as L
join fact_transactions as T
on T.IDLocation = L.IDLocation
join dim_customer as C
on C.IDCustomer = T.IDCustomer
join DIM_DATE as D
on D.DATE = T.Date
where YEAR between 2005 and YEAR(GETDATE())


--Q1--END

--Q2--BEGIN

select top 1 State , SUM(Quantity) Quant from DIM_LOCATION as L
join FACT_TRANSACTIONS as T
on L.IDLocation = T.IDLocation
join DIM_MODEL as M
on M.IDModel = T.IDModel
join DIM_MANUFACTURER  as MAN
on MAN.IDManufacturer = M.IDManufacturer
where Country = 'US' and Manufacturer_Name = 'Samsung'
group by State
order by Quant desc	




--Q2--END

--Q3--BEGIN      
	
	select  distinct Model_Name ,  ZipCode , State,  COUNT(*) as No_of_transactions from DIM_MODEL as M
join FACT_TRANSACTIONS as T
on M.IDModel = T.IDModel
join DIM_LOCATION as L
on L.IDLocation = T.IDLocation
group by Model_Name , state , ZipCode


--Q3--END

--Q4--BEGIN

select top 1 Model_Name ,IDModel ,MIN(Unit_price) as Price from DIM_MODEL 
group by Model_Name  , IDModel
order by Price



--Q4--END

--Q5--BEGIN


select model_name ,Manufacturer_Name, AVG(Unit_price) as Avg_Unit_price from DIM_MODEL as MO
inner join DIM_MANUFACTURER as MAN
on MO.IDManufacturer = MAN.IDManufacturer
where Manufacturer_Name   in (
select Top 5 Manufacturer_name  from FACT_TRANSACTIONS as T
join DIM_MODEL as MO
on MO.IDModel = T.IDModel  
join DIM_MANUFACTURER as MAN
on MO.IDManufacturer = MAN.IDManufacturer
group by  Manufacturer_Name
order by SUM(quantity) desc
)
group by Model_Name , Manufacturer_Name
order by Avg_Unit_price desc


--Q5--END

--Q6--BEGIN

select customer_name , AVG(TotalPrice) as Avg_amt from DIM_CUSTOMER as C
join FACT_TRANSACTIONS as T
on T.IDCustomer = C.IDCustomer
join DIM_DATE as D
on D.DATE = T.Date
where YEAR(T.Date) = 2009 
group by Customer_Name 
having AVG(totalprice) >500

--Q6--END
	
--Q7--BEGIN  

select * from
(select top 5 Model_name , SUM(quantity) as _Quantity from DIM_MODEL as M
join FACT_TRANSACTIONS as T
on M.IDModel = T.IDModel
join DIM_DATE as D
on D.DATE = T.Date
where YEAR = 2008
group by Model_Name
order by _Quantity desc

Intersect

select top 5 Model_name , SUM(quantity) as _Quantity from DIM_MODEL as M
join FACT_TRANSACTIONS as T
on M.IDModel = T.IDModel
join DIM_DATE as D
on D.DATE = T.Date
where YEAR = 2009
group by Model_Name
order by _Quantity desc


Intersect

select top 5 Model_name , SUM(quantity) as _Quantity from DIM_MODEL as M
join FACT_TRANSACTIONS as T  
on M.IDModel = T.IDModel
join DIM_DATE as D
on D.DATE = T.Date
where YEAR = 2010
group by Model_Name
order by _Quantity desc

) as A
	
	

--Q7--END	
--Q8--BEGIN

select Manufacturer_Name as Manufacturer_1_2009_2_2010 from
(
select top 1 Manufacturer_name  from
(
select  top 2 Manufacturer_name ,   sum(totalprice*Quantity) as _sum   from DIM_MANUFACTURER as MAN
join DIM_MODEL as MO
on MAN.IDManufacturer = MO.IDManufacturer
join FACT_TRANSACTIONS as T
on MO.IDModel = T.IDModel
join DIM_DATE as D
on D.DATE = T.Date
where YEAR = 2009 
group by Manufacturer_Name
order by _sum desc
) as A
order by _sum  

UNION

select top 1 Manufacturer_name  from 
(
select  top 2 Manufacturer_name ,   sum(totalprice*Quantity) as _sum   from DIM_MANUFACTURER as MAN
join DIM_MODEL as MO
on MAN.IDManufacturer = MO.IDManufacturer
join FACT_TRANSACTIONS as T
on MO.IDModel = T.IDModel
join DIM_DATE as D
on D.DATE = T.Date
where YEAR = 2010 
group by Manufacturer_Name
order by _sum desc
) as B
order by _sum 
) as C
order by Manufacturer_Name desc


--Q8--END

--Q9--BEGIN
	
select Distinct  Manufacturer_name  from DIM_MANUFACTURER as MAN
join DIM_MODEL as MO
on MAN.IDManufacturer = MO.IDManufacturer
join FACT_TRANSACTIONS as T
on MO.IDModel = T.IDModel
join DIM_DATE as D
on D.DATE = T.Date
where YEAR = 2010
except
select Distinct  Manufacturer_name as _sum   from DIM_MANUFACTURER as MAN
join DIM_MODEL as MO
on MAN.IDManufacturer = MO.IDManufacturer
join FACT_TRANSACTIONS as T
on MO.IDModel = T.IDModel
join DIM_DATE as D
on D.DATE = T.Date
where YEAR = 2009 


--Q9--END

--Q10--BEGIN


with A as (
select  top 100 YEAR ,customer_name , avg(quantity*TOTALprice) as Average_spend , avg(quantity) as Average_quantity ,
LAG(avg(quantity*TOTALprice)) over(PARTITION by customer_name  order by year) as Previous_year from DIM_CUSTOMER as C
join FACT_TRANSACTIONS as T
on C.IDCustomer = T.IDCustomer
join DIM_DATE as D
on D.DATE = T.Date
group by YEAR ,Customer_Name

)  
select [YEAR] , customer_name , Average_spend , Average_Quantity , coalesce((Average_spend-Previous_year)/Previous_year,0)*100 as Perc_change from A



    
--Q10--END
	