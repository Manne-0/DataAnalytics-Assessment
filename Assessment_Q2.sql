select
	case
		when freq_count_permonth <= 2 then 'Low Frequency'
		when freq_count_permonth between 3 and 9 then 'Medium frequency'
		else 'High Frequency'
	end as frequency_category,
	count(distinct id) customer_count,
	round(avg(freq_count_permonth), 1) average_transaction_per_month
from
	(
	select
		uc.id,
		CONCAT(uc.first_name , ' ', uc.last_name)name,
		count(distinct ss.transaction_reference)/ nullif(count(distinct date_format(ss.transaction_date, '%Y-%m')),0) as freq_count_permonth
	from
		users_customuser uc
	left join savings_savingsaccount ss 
on
		uc.id = ss.owner_id
	where
		transaction_date is not null
	group by
		uc.id,
		name) a /*  this inner query gives us all customers who have atleast made one transaction and the frequency of their transaction per month*/
group by
	frequency_category
order by
	average_transaction_per_month desc /*the outer quesry gives us the segmentation of the customers and their average transaction per month*/
