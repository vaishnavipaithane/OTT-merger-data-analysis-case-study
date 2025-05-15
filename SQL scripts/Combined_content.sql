-- content analysis
with combined_content AS (
	select 'Jotstar' AS platform, content_type, language, genre, run_time
	from jotstar_db.contents
	union all
	select 'LioCinema' AS platform, content_type, language, genre, run_time
	from liocinema_db.contents)
select platform, content_type, language, genre,
COUNT(*) AS total_titles, 
sum(run_time) AS total_runtime_mins
from combined_content
GROUP BY platform, content_type, language, genre
ORDER BY platform, total_titles DESC;