--1  for each director count the no of movies and tv shows created by them in separate columns
--for directors who have created tv shows and movies both


select
nd.director,
sum(case when type = 'movie' then 1 else 0 end) as movie_count,
sum(case when type = 'TV Show' then 1 else 0 end) as TV_Show_count
FROM netflix_directors as nd
left join netflix n on nd.show_id = n.show_id
group by nd.director
having sum(case when type = 'movie' then 1 else 0 end)>0 and sum(case when type = 'TV Show' then 1 else 0 end)>0











--2 which country has highest number of comedy movies 
with cte as
	(
	select
	nc.*,
	n.type,ng.genre
	FROM netflix_country as nc
	inner join netflix n on nc.show_id = n.show_id
	inner join netflix_genre as ng on ng.show_id = nc.show_id 
	where n.type= 'movie' and ng.genre  = 'Comedies'

	)
	select 
	top 1
	country, count(genre) as movie_count
	FROM CTE
	group by country 
	order by count(genre) desc





--3 for each year (as per date added to netflix), which director has maximum number of movies released
with cte as
	(
	select 
	datepart(year, date_added) as movie_year, nd.director,
	count(title) as no_of_movies
 
	FROM netflix as n
	inner join netflix_directors as nd on n.show_id = nd.show_id
	where n.type = 'movie'
	group by datepart(year, date_added), nd.director
	)
	select movie_year, director, no_of_movies, rnk from(
	select 
	*,
	rank() over(partition by movie_year order by no_of_movies desc) as rnk
	from cte
	) as temp where rnk = 1




--4 what is average duration of movies in each genre
with cte as
	(
	select 
	n.show_id,
	substring(duration,1 ,CHARINDEX(' ', duration)-1) as duration,
	ng.genre
	FROM netflix as n
	inner join netflix_genre as ng on n.show_id = ng.show_id
	where n.type = 'Movie'
	)
	select 
	genre, AVG(cast(duration as int)) as avg_duration
	FROM cte
	group by genre





--5  find the list of directors who have created horror and comedy movies both.
-- display director names along with number of comedy and horror movies directed by them 
select 
nd.director,
sum(case when ng.genre IN ('Comedies') then 1 else 0 end) as comedy_movie_count,
sum(case when ng.genre IN ('Horror Movies') then 1 else 0 end) as horror_movie_count
FROM netflix_directors as nd 
inner join  netflix_genre as ng on nd.show_id = ng.show_id
inner join netflix as n on n.show_id = nd.show_id
where n.type = 'movie' and ng.genre IN ('Comedies', 'Horror Movies')
group by nd.director
having count(distinct ng.genre) =2 
