SELECT * FROM [sohag].[dbo].[museum_hours] as mh
SELECT * FROM [sohag].[dbo].[artist] as a
select * from [sohag].[dbo].canvas_size as c
select * from [sohag].[dbo].museum as m 
select * from [sohag].[dbo].product_size as p
select * from [sohag].[dbo].subject as s
select * from [sohag].[dbo].work as w


/* problem 1 : Fetch all the paintings which are not displayed on any museums? */
/*solution 1*/
select w.name from [sohag].[dbo].work as w 
where w.museum_id is null
















/* problem 2 : Are there museums without any paintings? */


select m.museum_id  from [sohag].[dbo].museum as m 
join [sohag].[dbo].work as w on w.museum_id = m.museum_id
group by m.museum_id
having count(w.work_id)=0





/* problem 3: How many paintings have an asking price of more than their regular price? */

select  count(p.work_id) from [sohag].[dbo].product_size as p
where p.sale_price>p.regular_price







/* problem 4: Identify the paintings whose asking price is less than 50% of its regular price */

select  p.work_id,
p.sale_price,
p.regular_price
from [sohag].[dbo].product_size as p
where p.sale_price<(p.regular_price*0.5)






/*problem 5:  Which canva size costs the most?*/

with cte as 
(select c.size_id as size ,
p.regular_price as r_price,
rank() over(order by p.regular_price desc) as rnk 
from [sohag].[dbo].product_size as p
join [sohag].[dbo].canvas_size as c on c.size_id = p.size_id)

select size,r_price,rnk from cte 
where rnk = 1






/*problem  6: Delete duplicate records from work, product_size, subject and image_link tables */

select w.name,w.artist_id,w.style,w.museum_id,count(*) as cnt from [sohag].[dbo].work as w
group by w.name,w.artist_id,w.style,w.museum_id
having count(*)>1

with cte as(select w.name,w.artist_id,w.style,w.museum_id,
ROW_NUMBER() over(partition by w.work_id order by w.work_id) as rnk
from [sohag].[dbo].work as w)
select * from cte 
where rnk>1

select w.name,w.artist_id,w.style,w.museum_id,count(w.name) from [sohag].[dbo].work as w
group by w.name,w.artist_id,w.museum_id,w.style
having count(w.name) >1



/* solution 6: Delete duplicate records from work, product_size, subject and image_link tables  */
with cte as
(select w.name,w.artist_id,w.style,w.museum_id,
ROW_NUMBER() over(partition by w.name,w.artist_id,w.style,w.museum_id order by w.work_id) as rnk
from [sohag].[dbo].work as w)
delete from cte 
where rnk>1






/*Problem 7 : Identify the museums with invalid city information in the given dataset */
select m.city 
from [sohag].[dbo].museum as m 
where m.city like '%[0-9]%'







/* problem 8: Museum_Hours table has 1 invalid entry. Identify it and remove it. */
Select distinct day FROM [sohag].[dbo].[museum_hours] as mh
Delete FROM [sohag].[dbo].[museum_hours] 
where day ='Thusday'




/*problem 9 :Fetch the top 10 most famous painting subject  */
select top 10 subject,
cnt from(select s.subject,count(*) cnt 
from [sohag].[dbo].subject as s
group by s.subject) w
order by cnt desc






/* problem 10: Identify the museums which are open on both Sunday and Monday. Display museum name, city.  */
SELECT distinct mh.museum_id,
m.name,m.city 
FROM [sohag].[dbo].[museum_hours] as mh
join [sohag].[dbo].museum as m on m.museum_id = mh.museum_id
where mh.day  in('Sunday' , 'Monday') and mh.[close]> mh.[open]






/* problem 11 How many museums are open every single day?  */

with cte as (
    SELECT m.name, 
	COUNT(mh.day) as no_of_day 
	from [sohag].[dbo].museum as m 
    JOIN [sohag].[dbo].[museum_hours] as mh ON m.museum_id = mh.museum_id
    GROUP by name 
    HAVING COUNT(mh.day) = 7
)
SELECT count(1) from cte





/* problem 12: Which are the top 5 most popular museum?
(Popularity is defined based on most no of paintings in a museum)  */

with cte as (
select m.name,
count(w.work_id) no_of_paintings ,
rank() over(order by count(w.work_id) desc) as rnk
from [sohag].[dbo].work as w
join [sohag].[dbo].museum as m  on m.museum_id = w.museum_id
group by m.name)
select name,no_of_paintings from cte 
where rnk <= 5






/* problem 13 :Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist) */
with cte as (
select a.full_name as name,
count(w.work_id) no_of_paintings,
rank() over(order by count(w.work_id) desc) as rnk 
from [sohag].[dbo].work as w
join [sohag].[dbo].[artist] as a on a.artist_id = w.artist_id
group by a.full_name)
select name from cte 
where rnk <= 5




/* problem 14 : Display the 3 least popular canva sizes*/

with cte as 
(select *, COALESCE(c.height,0)*COALESCE(c.width,0) as area
from [sohag].[dbo].canvas_size as c),
rnk as (select *, ROW_NUMBER() over(order by area) as rk from cte 
where area != 0)

select size_id from rnk
where rk<=3



/* problem  15 :Which museum has the most no of most popular painting style?  */

with cte as (
select m.name as name,
count(w.style) as no_style,
ROW_NUMBER() over(order by count(w.style) desc) as rnk 
from [sohag].[dbo].work as w
join [sohag].[dbo].museum as m on m.museum_id = w.museum_id
group by m.name)

select name from cte 
where rnk=1



/* problem 16 : Identify the artists whose paintings are displayed in multiple countries */


with cte as(
select w.artist_id as id,a.full_name as f_name, count(distinct m.country) no_of_country,
ROW_NUMBER() over(order by count(distinct m.country) desc) as rnk
from [sohag].[dbo].work as w
join [sohag].[dbo].[artist] as a on a.artist_id = w.artist_id
join [sohag].[dbo].museum as m on m.museum_id = w.museum_id
group by w.artist_id,a.full_name)
select f_name,no_of_country from cte 
where rnk = 1



/* solution 17 :Display the country and the city with most no of museums. 
Output 2 seperate columns to mention the city and country. 
If there are multiple value, seperate them with comma. */

with cte as (
select m.country country,
STRING_AGG(m.city,',') as city,
count(m.museum_id) as no_of_museum,
ROW_NUMBER() over(order by count(m.museum_id) desc) as rnk
from [sohag].[dbo].museum as m
group by m.country)

select country,city,no_of_museum from cte 
where rnk=1



/* problem 18 : Identify the artist and the museum where the most expensive and
least expensive painting is placed.Display the artist name, sale_price, 
painting name, museum name, museum city and canvas label */

with cte as (select a.full_name as f_name,
p.sale_price as sale_price,
w.name as printing,
m.name as museum_name,
m.city as city,
c.label as lable,
ROW_NUMBER() over(order by p.sale_price desc) as rnk 
from [sohag].[dbo].product_size as p
join [sohag].[dbo].work as w on w.work_id = p.work_id
join [sohag].[dbo].[artist] as a on a.artist_id=w.artist_id
join [sohag].[dbo].museum as m on m.museum_id =w.museum_id
join [sohag].[dbo].canvas_size as c on c.size_id =p.size_id)
select f_name,sale_price,printing,museum_name,city,lable from cte
where rnk = 1 /*or rnk= (select count(1) from cte)*/



/*problem 19: Which country has the 5th highest no of paintings? */

with cte as (select m.country as country,count(w.work_id) as no_of_painting,
ROW_NUMBER() over(order by count(w.work_id) desc) as rnk 
from [sohag].[dbo].museum as m 
join [sohag].[dbo].work as w on w.museum_id = m.museum_id
group by m.country)
select country from cte
where rnk =5








/* problem 20:Which are the 3 most popular and 3 least popular painting styles?  */
with cte as(
select  w.style style,
count(w.work_id) no_of_paintings,
ROW_NUMBER() over(order by count(w.work_id) desc) rnk
from [sohag].[dbo].work as w
where w.style is not null
group by w.style)
select * from cte
where rnk =3 or rnk = (select count(1)-3 from cte)





/* problem 21: Which artist has the most no of Portraits paintings outside USA?. 
Display artist name, no of paintings and the artist nationality. */
with cte as (
select a.full_name,
m.country country,
count(s.work_id) no_of_painting,
ROW_NUMBER() over(order by count(s.work_id) desc) as rnk
from [sohag].[dbo].subject as s
join [sohag].[dbo].work as w on w.work_id = s.work_id
join [sohag].[dbo].museum as m on m.museum_id = w.museum_id
join [sohag].[dbo].[artist] as a on a.artist_id = w.artist_id
where s.subject = 'Portraits' and m.country != 'USA'
group by a.full_name,m.country
)
select full_name,country,no_of_painting from cte
where rnk =1

