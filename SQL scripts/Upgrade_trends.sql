-- Subscription Upgrade Trends: Users upgrading their plans
with Upgraded_users AS (
	select platform,
    subscription_plan AS upgraded_from,
    new_subscription_plan AS upgraded_to,
    count(*) AS upgraded_users
    from (
		select 'Jotstar' AS platform, subscription_plan, new_subscription_plan
		from jotstar_db.subscribers
        where new_subscription_plan is not null
			and subscription_plan is not null
			and (
                  (subscription_plan = 'Free' and new_subscription_plan in ('VIP', 'Premium'))  -- Free → VIP/Premium
                  or (subscription_plan = 'VIP' and new_subscription_plan = 'Premium')  -- VIP → Premium
              )
            and subscription_plan <> new_subscription_plan
            
		union all
        
        select 'LioCinema' AS platform, subscription_plan, new_subscription_plan
        from liocinema_db.subscribers
        where new_subscription_plan is not null
			and subscription_plan is not null
			and (
                  (subscription_plan = 'Free' and new_subscription_plan in ('Basic', 'Premium'))  -- Free > Basic/Premium
                  or (subscription_plan = 'Basic' and new_subscription_plan = 'Premium')  -- Basic > Premium
              )
            and subscription_plan <> new_subscription_plan
	) AS upgrade_data
    group by platform, subscription_plan, new_subscription_plan
    )
    select * from Upgraded_users;