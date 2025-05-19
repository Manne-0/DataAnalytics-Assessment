select
	uc.id as customer_id,
	CONCAT(uc.first_name, ' ', uc.last_name) as name,
	ROUND(DATEDIFF(CURDATE(), uc.date_joined) / 30) as tenure_months,
	COUNT(ss.transaction_reference) as total_transactions,
	ROUND(
        (
            (COUNT(ss.transaction_reference) / nullif(ROUND(DATEDIFF(CURDATE(), uc.date_joined) / 30), 0)) 
            * 12 
            * (SUM(0.001 * ss.confirmed_amount) / nullif(COUNT(ss.transaction_reference), 0))
        ) / 100,      /*converts amount to Naira*/
    2) as estimated_clv
from
	users_customuser uc
left join savings_savingsaccount ss 
    on
	uc.id = ss.owner_id
group by
	uc.id,
	uc.first_name,
	uc.last_name,
	uc.date_joined
order by
	estimated_clv desc;