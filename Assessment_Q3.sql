select
	id,
	owner_id,
	last_transaction_date,
	DATEDIFF(CURDATE(), last_transaction_date) as inactivity_days
from
	(
	select
		pp.id,
		pp.owner_id,
		pp.is_a_fund,
		pp.is_regular_savings,
		coalesce(cast(MAX(ss.transaction_date) as date), '1900-01-01') as last_transaction_date,
		case
			when pp.is_a_fund = 1 then 'Investment'
			when pp.is_regular_savings = 1 then 'Savings'
		end as type
	from
		plans_plan pp
	left join savings_savingsaccount ss 
        on
		pp.id = ss.plan_id
	where
		pp.is_a_fund = 1
		or pp.is_regular_savings = 1
	group by
		pp.id,
		pp.owner_id,
		pp.is_a_fund,
		pp.is_regular_savings
) as account_activity
having
	inactivity_days > 365
order by
	last_transaction_date desc;
