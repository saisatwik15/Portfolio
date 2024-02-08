1)Fetch all the paintings which are not displayed on any museums?
select * from work where museum_id is null;


2)Are there museuems without any paintings?
select * from museum m
where not exists (select 1 from work w
			where w.museum_id=m.museum_id)


3)How many paintings have an asking price of more than their regular price? 
select * from product_size
where sale_price > regular_price;


4) Identify the paintings whose asking price is less than 50% of its regular price
	select * 
	from product_size
	where sale_price < (regular_price*0.5);


5)Which canva size costs the most?
select cs.label as canva, ps.sale_price
from (select *, rank() over(order by sale_price desc) as rnk 
from product_size) ps
join canvas_size cs on cs.size_id::text=ps.size_id
where ps.rnk=1;					 

6) Delete duplicate records from work, product_size, subject and image_link tables
delete from work 
where ctid IN (select ctid from 
(select ctid, work_id, name, artist_id, style, museum_id, 
ROW_NUMBER() over (partition by work_id, name, artist_id, style, museum_id order by work_id) as row_number
from work) as x
where row_number > 1);

with product_size_dup as (
Select ctid, work_id, size_id,sale_price, regular_price,
ROW_NUMBER() OVER(PARTITION BY work_id, size_id,sale_price, regular_price ORDER BY work_id) as row_number
from product_size) 
delete from product_size where ctid In (select ctid from product_size_dup where row_number > 1)


delete from subject where ctid in (select ctid from (select ctid, work_id, subject,
row_number() over(partition by work_id, subject order by work_id ) as row_number
from subject) x 
where row_number >1)

with dup_image_links as(
select work_id, url,thumbnail_small_url,thumbnail_large_url,
	row_number() over (partition by work_id, url,thumbnail_small_url,thumbnail_large_url order by work_id) as row_number
from image_link)
(select work_id from dup_image_links where row_number>1)

delete from image_link where work_id in (select work_id from dup_image_links where row_number>1)

7) Identify the museums with invalid city information in the given dataset

select count(*), city from museum
where city ~'[0-9!@#$%^&*(),.?":{}|<>]'
group by 2;

8) Museum_Hours table has 1 invalid entry. Identify it and remove it.
select * from museum_Hours
where museum_id isnull or day isnull or open isnull or close isnull
select * from museum_Hours
where museum_id::text = '' or day::text = '' or open::text = '' or close::text = ''

select distinct(open) from museum_Hours
order by open

select distinct(close) from museum_Hours
order by close

9) Fetch the top 10 most famous painting subject
select * from subject
select * from work

select * from (
	select s.subject, count(*) as Total_number_of_Paintings, rank() over(order by count(*) desc) as rank
	from subject s
	join work w
	on s.work_id=w.work_id
	group by s.subject) as x
where rank <=10;

10) Identify the museums which are open on both Sunday and Monday. Display museum name, city.

select * from museum;
select * from museum_hours;

select mh.museum_id,m.name,m.city,m.phone 
from museum_hours mh
join museum m
on mh.museum_id =m.museum_id
where mh.day = 'Sunday' and mh.museum_id in
	(select museum_id from museum_hours
	where day = 'Monday' )
	
11) How many museums are open every single day?

select count(*) as Total_museumns_open_allweek  from 
	(select museum_id,count(*) as Number_of_museumns_open from museum_hours
	group by museum_id
	having count(*) >6) as x


12) Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)
select m.name as museum, m.city,m.country,x.no_of_painintgs
	from (	select m.museum_id, count(1) as no_of_painintgs
			, rank() over(order by count(1) desc) as rnk
			from work w
			join museum m on m.museum_id=w.museum_id
			group by m.museum_id) x
	join museum m on m.museum_id=x.museum_id
	where x.rnk<=5;


13) Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)
	select a.full_name as artist, a.nationality,x.no_of_painintgs
	from (	select a.artist_id, count(1) as no_of_painintgs
			, rank() over(order by count(1) desc) as rnk
			from work w
			join artist a on a.artist_id=w.artist_id
			group by a.artist_id) x
	join artist a on a.artist_id=x.artist_id
	where x.rnk<=5;
	
14) Display the 3 least popular canva sizes
	
select label,ranking,no_of_paintings
	from (
		select cs.size_id,cs.label,count(1) as no_of_paintings
		, dense_rank() over(order by count(1) ) as ranking
		from work w
		join product_size ps on ps.work_id=w.work_id
		join canvas_size cs on cs.size_id::text = ps.size_id
		group by cs.size_id,cs.label) x
	where x.ranking<=3;
	
15) Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?
select * from museum;
select * from museum_hours;

Select * from (	
	select m.name as Museum_name,m.city,m.state,
	to_timestamp(open,'HH:MI AM') as open_time,
	to_timestamp(close,'HH:MI PM') as close_time,
	to_timestamp(close,'HH:MI AM') - to_timestamp(open,'HH:MI PM') as hours_open,
	rank() over(order by (to_timestamp(close,'HH:MI AM') - to_timestamp(open,'HH:MI PM')) desc) as Ranking
	from museum_hours mh
	join museum m
	on mh.museum_id = m.museum_id) x
where x.Ranking =1;

16) Which museum has the most no of most popular painting style?

select * from museum;
select * from work;

EXPLAIN (ANALYZE, TIMING)(with cte as(
	select w.style, count(*) as Total_no_of_paintings,m.name,
	rank() over(order by count(*) desc) as ranking
	from work w
	join museum m
	on w.museum_id=m.museum_id
	where w.museum_id is not null
	group by style,m.name)
	
Select name, style, Total_no_of_paintings
from cte where ranking =1)

with pop_style as 
			(select style
			,rank() over(order by count(1) desc) as rnk
			from work
			group by style),
		cte as
			(select w.museum_id,m.name as museum_name,ps.style, count(1) as no_of_paintings
			,rank() over(order by count(1) desc) as rnk
			from work w
			join museum m on m.museum_id=w.museum_id
			join pop_style ps on ps.style = w.style
			where w.museum_id is not null
			and ps.rnk=1
			group by w.museum_id, m.name,ps.style)
	select museum_name,style,no_of_paintings
	from cte 
	where rnk=1
	
17) Identify the artists whose paintings are displayed in multiple countries

select * from artist;
select * from museum;
select * from work;

with cte as(
	select distinct(w.artist_id),m.country,a.full_name as artist_name
	from museum m 
	join work w
	on m.museum_id = w.museum_id
	join artist a on w.artist_id = a.artist_id)

select artist_name, count(*) as no_of_countries
from cte
group by artist_name
having count(*)>1
order by no_of_countries desc

18) Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and country. If there are multiple value, seperate them with comma.

select * from museum;

with country_cte as(
	select country, count(*) as no_of_museums,
	rank() over(order by count(*) desc) as rank
	from museum
	group by country),
 city_cte as (
	select city, count(*) as no_of_museums,
	rank() over(order by count(*) desc) as rank
	from museum
	group by city)
	
select string_agg(distinct(country),',')country, string_agg(city, ',')  city
from country_cte co
cross join city_cte cc
where co.rank=1
and cc.rank=1

19) Identify the artist and the museum where the most expensive and least expensive painting is placed. 
Display the artist name, sale_price, painting name, museum name, museum city and canvas label

select * from product_size;
select max(regular_price) from product_size;
select * from artist;
select * from museum;
select * from work;
select * from canvas_size;

with cte as(
	select 
		a.full_name as artist_name, 
		ps.sale_price as price,
		w.name as painting_name,
		m.name as museum_name,
		m.city as museum_city,
		c.label as canvas_label
	from product_size ps
	join work w on w.work_id = ps.work_id
	join artist a on w.artist_id=a.artist_id
	join museum m on m.museum_id=w.museum_id
	join canvas_size c on c.size_id::text=ps.size_id)
select artist_name,price,painting_name,museum_name,museum_city,canvas_label
from cte
where price in (select max(price) from cte)
or price in (select min(price) from cte)

20) Which country has the 5th highest no of paintings?
select * from museum;
select * from work;

with top5 as(
	Select m.country, count(*) as no_of_paintings,
	rank() over(order by count(*) desc) as rank
	from museum m
	join work w
	on m.museum_id=w.museum_id
	group by country)
	
select * from top5
where rank=5;

21) Which are the 3 most popular and 3 least popular painting styles?

with cte as 
	(select style, count(*) as No_of_paintings,
		rank() over(order by count(*) desc) rank,
		count(*) over() as no_of_records
		from work
		where style is not null
		group by style)
select style,
case when rank <=3 then 'Most Popular' else 'Least Popular' end as remarks 
from cte
where rank <=3
or rank > no_of_records - 3;

22) Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality.
select * from artist;
select * from museum;
select * from work; 

with cte as(
	Select a.full_name as name, a.nationality,a.style, count(*) as no_of_paintings,
	rank() over (order by count(*) desc) as rank
	from work w
	join artist a
	on w.artist_id=a.artist_id
	join museum m on m.museum_id=w.museum_id
	where a.style like'Portrait%' 
	and country <> 'USA'
	group by a.style,a.full_name,a.nationality)
	
select * from cte
where rank=1;




