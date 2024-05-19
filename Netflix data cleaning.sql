--remove duplicates and data type conversions for date added 

select show_id,COUNT(*) 
from netflix_raw
group by show_id 
having COUNT(*)>1

select * from netflix_raw
where concat(upper(title),type)  in (
select concat(upper(title),type) 
from netflix_raw
group by upper(title) ,type
having COUNT(*)>1
)
order by title

with cte as (
select * 
,ROW_NUMBER() over(partition by title , type order by show_id) as rn
from netflix_raw
)
select show_id,type,title,cast(date_added as date) as date_added,release_year
,rating,case when duration is null then rating else duration end as duration,description
into netflix
from cte 




--new table for listed_in(genre),director, country,cast

select show_id , trim(value) as genre
into netflix_genre
from netflix_raw
cross apply string_split(listed_in,',')


select show_id , trim(value) as cast
into netflix_cast
from netflix_raw
cross apply string_split(cast,',')



select show_id , trim(value) as director
into netflix_directors
from netflix_raw
cross apply string_split(director,',')


select show_id , trim(value) as country
into netflix_country
from netflix_raw
cross apply string_split(country,',')




----find unique director and country combinations
select 
nd.director, nc.country
FROM netflix_directors as nd inner join netflix_country as nc ON nd.show_id = nc.show_id
group by nd.director, nc.country
having nd.director = 'Omoni Oboli'
order by director




----fill null values of country
insert into netflix_country
select 
nr.show_id, m.country
FROM netflix_raw as nr
inner join 
			(
			select 
			nd.director, nc.country
			FROM netflix_directors as nd inner join netflix_country as nc ON nd.show_id = nc.show_id
			group by nd.director, nc.country
			) 
m on nr.director = m.director
where nr.country is null





