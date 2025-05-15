-- monthly new users
select
platform,
date_format(subscription_date, '%Y-%m') AS month,
count(user_id) AS new_users
from (
	select 'Jotstar' AS platform, user_id, subscription_date
    from jotstar_db.subscribers
	union all
	select 'LioCinema' AS platform, user_id, subscription_date
    from liocinema_db.subscribers
    ) AS combined_subscribers
group by platform, month
order by platform, month;