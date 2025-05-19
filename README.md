# DataAnalytics-Assessment
## Assessment Q1 - High-Value Customers with Multiple Products
To identify customers who have both a funded savings plan and a funded investment plan, I structured the query using Common Table Expressions (CTEs) for clarity and efficiency:
1. Question 1 - High-Value Customers with Multiple Products
Filtered CTE (filtered)
Retrieves all customers with either a savings or investment plan that has at least one deposit.
Converts confirmed_amount from kobo to naira for readability.
Uses LEFT JOIN on plans_plan and savings_savingsaccount to associate deposits with plans.
2. Aggregation CTE (aggregation)
Computes the count of savings and investment plans per customer.
Aggregates total deposits per plan type using SUM().
Uses COALESCE() to handle possible NULL values, ensuring correct total calculations.
3. Final Query:
Filters only customers who have both a savings and an investment plan (savings_count >= 1 AND investment_count >= 1).
Calculates total deposits per customer and ranks results in descending order of deposit amount (ORDER BY total_deposit DESC).

### Challenges
1. Overcounting Deposits
Initially, joining on owner_id would have included all deposits made by the customer across different plans, which didn't separate savings from investments.
***Solution:*** Join using plan_id to ensure deposits are grouped correctly under the right plan type (savings vs. investment)


## Assessment Q2 - Transaction Frequency Analysis
#### Approach: 
To segment customers based on transaction frequency, I implore the use of subqueries and designed the query to:
1. Calculate the average number of transactions per customer per month (inner query).
2. Categorize customers into High, Medium, and Low Frequency users based on their monthly transaction volume(outer query).

#### Challenges
1. Handling Cases With No Transactions (Null transaction date): Customers with no transaction date were leading to NULL or division by and thereby distorting the freq_count_permonth.
***Solution:*** Exclude NULL transaction date to only calculate frequency based on actual activity. This prevents inflated ratios and ensures accurate customer categorization.



## 
