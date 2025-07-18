SET SQL_SAFE_UPDATES = 0;


select * from cafe_sales;


-- make a copy of raw dataset
create table cafe
like cafe_sales;

select * from cafe;

insert cafe
select * from cafe_sales;


-- checking for duplicates
with ranked as(
select *,
row_number() over(partition by `Transaction ID`) as row_num
from cafe
)
select *
from ranked
where row_num >1 ;


-- checking for null values and blanks
select * 
from cafe
where `Transaction ID` is null and `Transaction ID` = ' ';


select * from cafe;

-- item column

select distinct item from cafe;

update cafe
set item = trim(item);

update cafe
set item = null
where item = '' OR item in ('UNKNOWN','ERROR');

-- quantity and price per unit
select * from
cafe 
where quantity<=0 or `price per unit`<=0;

-- total spent
select * from cafe;

select * from 
cafe 
where `Total Spent` != Quantity * `Price Per Unit`;

update cafe
set `Total Spent` = Quantity * `Price Per Unit`;

-- Payment method

select * from cafe;

select distinct `Payment Method` from cafe;

update cafe
set `Payment Method` = null
where `Payment Method` = '' or `Payment Method` in ('UNKNOWN','ERROR') ;


-- location
update cafe
set location = null
where location = '' or location in ('ERROR','UNKNOWN');

-- transaction date

select * from cafe;


update cafe
set `Transaction Date` = null
where `Transaction Date` = '' or `Transaction Date` in ('ERROR', 'UNKNOWN');


select distinct `Transaction Date` from cafe;
update cafe
set `Transaction Date` = str_to_date(`Transaction Date`, '%d/%m/%Y')
where `Transaction Date` like '%/%';

-- changing data types

select * from cafe;

desc cafe;

alter table cafe modify `Transaction ID` varchar(30);

alter table cafe add primary key (`Transaction ID`);

alter table cafe modify `Price Per Unit` Decimal(10,2);

alter table cafe modify `Total Spent` Decimal(10,2);

alter table cafe modify `Payment Method` varchar(30);

alter table cafe modify `Location` varchar(30);

alter table cafe modify `Transaction Date` date;



-- insights from data

-- top selling item
select sum(quantity) as sales,item
from cafe
group by item
order by sales desc;

-- revenue per item
select sum(`Total Spent`) as revenue,item
from cafe
group by item
order by revenue desc;

-- average order value
select avg(`Total Spent`)
from cafe;

-- payment method popularity

select `Payment Method`, 
		count(`Payment Method`)/ (select count(`Payment Method`) from cafe)  * 100   as popularity
from cafe
group by `Payment Method`
order by popularity desc;

-- location performance

select Location, sum(`Total Spent`) as Loc_Sales
from cafe
group by Location
order by Loc_Sales desc; 


-- monthly sales trend

select DATE_FORMAT(`Transaction Date`, '%Y-%m') as month, sum(`Total Spent`) as revenue
from cafe
group by  month
order by month asc;

-- peak sale day

select dayname(`Transaction Date`) as day, sum(`Total Spent`) as revenue
from cafe
group by dayname(`Transaction Date`)
order by revenue desc;

-- best item per month

select item, month,revenue
from(
	select item, 
		   month(`Transaction Date`) as month, 
           sum(`Total Spent`) as revenue, 
           rank() over (partition by month(`Transaction Date`)  order by sum(`Total Spent`) desc) as rnk
    from cafe
    group by item, month(`Transaction Date`)
) as ranked
where rnk = 1
order by month;


-- high value transaction


select `Total Spent` ,`Transaction ID`
from cafe
where `Total Spent`> (select avg(`Total Spent`) from cafe)
order by `Total Spent`;


-- 3 sigma method for extreme outliers

SELECT `Transaction ID`, `Total Spent`
FROM cafe
WHERE `Total Spent` > (
    SELECT AVG(`Total Spent`) + 3 * STDDEV(`Total Spent`)
    FROM cafe
)
ORDER BY `Total Spent` DESC;

	









