select
	distinct id,
	owner_id,
	last_transaction_date,
	DATEDIFF(CURDATE(), last_transaction_date) inactivity_days
from
	(
	select
		pp.id,
		pp.owner_id,
		is_a_fund ,
		is_regular_savings ,
		max(ss.transaction_date) last_transaction_date,
		case
			when is_a_fund = 1 then 'Investment'
			when pp.is_regular_savings = 1 then 'Savings'
		end as type
		-- , ss.confirmed_amount, ss.transaction_date
	from
		plans_plan pp
	left join savings_savingsaccount ss 
on
		pp.id = ss.plan_id
	where
		(pp.is_a_fund = 1
			or is_regular_savings = 1)
	group by
		pp.id,
		pp.owner_id,
		is_a_fund,
		is_regular_savings,
		type
		-- and ss.confirmed_amount != 0 /*takes out potential failed transaction*/
)a
having
	inactivity_days > 365
order by
	a.last_transaction_date desc