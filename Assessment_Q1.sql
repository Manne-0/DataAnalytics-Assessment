/* This gets all customers with either a FUNDED savings acount or fUNDED investment account and the amount deposited per plan.*/
WITH filtered AS (
SELECT 
			pp.owner_id,
			CONCAT(uc.first_name , ' ', uc.last_name) as name,
			pp.is_a_fund ,
			pp.is_regular_savings,
			pp.id,
			ss.confirmed_amount/100 confirmed_amount /*convert the amount field from kobo to naira*/
FROM
			users_customuser uc
LEFT JOIN plans_plan pp 
on
			uc.id = pp.owner_id
LEFT JOIN savings_savingsaccount ss 
ON
			pp.id = ss.plan_id
WHERE
			(pp.is_a_fund = 1
	OR pp.is_regular_savings = 1)
	AND ss.confirmed_amount is not null),
/*this gets all the customers with the count of their plan per plan type and the associated deposits*/
aggregation AS (
SELECT
		owner_id,
		name,
		COUNT(DISTINCT CASE WHEN is_regular_savings = 1 THEN id END) AS savings_count,
		COUNT(distinct CASE WHEN is_a_fund = 1 THEN id END) AS investment_count,
		COALESCE(SUM(CASE WHEN is_regular_savings = 1 then confirmed_amount END), 0) AS total_deposit_savings,
		COALESCE(SUM(CASE WHEN is_a_fund = 1 THEN confirmed_amount END), 0) AS total_deposit_investment
FROM
	filtered
GROUP BY 
	owner_id,
	name
		)
/*This selects the customers who meet the criteria of having at least one savings plan AND one investment plan*/
SELECT
	owner_id,
	name,
	savings_count,
	investment_count,
	round(sum(total_deposit_savings + total_deposit_investment),2) as total_deposit
FROM
	aggregation
WHERE
	savings_count >= 1
	and investment_count >= 1
GROUP BY
	owner_id ,
	name
ORDER BY
	total_deposit DESC