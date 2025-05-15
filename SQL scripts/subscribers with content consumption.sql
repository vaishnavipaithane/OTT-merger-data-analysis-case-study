-- joining subscribers with content consumption based on user_id
with subscribers AS (
	select 'Jotstar' AS platform, user_id, age_group, city_tier, subscription_plan, last_active_date
	from jotstar_db.subscribers
    union all
    select 'LioCinema' AS platform, user_id, age_group, city_tier, subscription_plan, last_active_date
	from liocinema_db.subscribers
),
content_consumption AS (
	select 'Jotstar' AS platform, user_id, device_type, total_watch_time_mins
	from jotstar_db.content_consumption
    union all
    select 'LioCinema' AS platform, user_id, device_type, total_watch_time_mins
    from liocinema_db.content_consumption
)
select
s.platform,
s.user_id,
s.age_group,
s.city_tier,
s.subscription_plan,
case 
	when s.last_active_date is null 
                 or s.last_active_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) 
            then 'Active' 
            else 'Inactive' 
        end as user_status,
c.device_type,        
c.total_watch_time_mins
from subscribers s
join content_consumption c
	on s.platform = c.platform and s.user_id = c.user_id;