-- Subscription Downgrade Trends: Users downgrading their plans
with Downgraded_users AS (
	select platform,
    subscription_plan AS downgraded_from, 
    new_subscription_plan AS downgraded_to,
    count(*) AS downgraded_users
    from (
		select 'Jotstar' AS platform, subscription_plan, new_subscription_plan
		from jotstar_db.subscribers
        where new_subscription_plan is not null
			and subscription_plan is not null
			and ( 
					(subscription_plan = 'Premium' and new_subscription_plan in ('Free', 'VIP')) -- Premium > Free/VIP
				  or (subscription_plan = 'VIP' and new_subscription_plan = 'Free') -- VIP > Free
				) 
			and subscription_plan <> new_subscription_plan
            
		union all
        
        select 'LioCinema' AS platform, subscription_plan, new_subscription_plan
        from liocinema_db.subscribers
        where new_subscription_plan is not null
			and subscription_plan is not null
			and (
					(subscription_plan = 'Premium' and new_subscription_plan in ('Free','Basic')) -- Premium > Free/Basic
				 or (subscription_plan = 'Basic' and new_subscription_plan = 'Free') -- Basic > Free
				)
            and subscription_plan <> new_subscription_plan
	) AS downgrade_data
    group by platform, subscription_plan, new_subscription_plan
)
select * from Downgraded_users;