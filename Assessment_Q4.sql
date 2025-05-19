select
	id as customer_id,
	name,
	tenure,
	sum(trans_cnt) total_transactions,
	round(((trans_cnt / tenure) * 12 * avg_profit_per_transaction)/ 100, 2) estimated_clv /*divides by 100 to convert to naira*/
from
	(
	select
		uc.id,
		uc.created_on,
		CONCAT(uc.first_name , ' ', uc.last_name)name,
		round(DATEDIFF(CURDATE(), uc.created_on )/ 30) as tenure,
		count(ss.transaction_reference) trans_cnt,
		ss.confirmed_amount,
		sum(0.001 * ss.confirmed_amount)/ count(ss.transaction_reference) avg_profit_per_transaction  
	from
		users_customuser uc
	left join savings_savingsaccount ss 
on
		uc.id = ss.owner_id
	group by
		uc.id,
		uc.created_on,
		name,
		ss.confirmed_amount) a
group by
	id,
	name,
	tenure
order by
	5 desc