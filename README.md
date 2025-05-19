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

#### Challenges
1. Overcounting Deposits
Initially, joining on owner_id would have included all deposits made by the customer across different plans, which didn't separate savings from investments.
#### ***Solution:*** Join using plan_id to ensure deposits are grouped correctly under the right plan type (savings vs. investment)


## Assessment Q2 - Transaction Frequency Analysis
#### Approach: 
To segment customers based on transaction frequency, I implored the use of subqueries and designed the query to:
1. Calculate the average number of transactions per customer per month (inner query).
2. Categorize customers into High, Medium, and Low Frequency users based on their monthly transaction volume(outer query).

#### Challenges
1. Handling Cases With No Transactions (Null transaction date): Customers with no transaction date were leading to NULL or division by and thereby distorting the freq_count_permonth.
##### ***Solution:*** Exclude NULL transaction date to only calculate frequency based on actual activity. This prevents inflated ratios and ensures accurate customer categorization.



## Assessment Q3 - Account Inactivity Alert
#### Approach:
1. Filtered Active Plans: Selected plans marked as either is_regular_savings = 1 or is_a_fund = 1 from the plans_plan table to represent active accounts.
2. Joined Transactions: Used a LEFT JOIN with the savings_savingsaccount table on plan_id to capture any associated transaction records — this ensures plans without any transactions are still included.
3. Identified Latest Activity: Aggregated by plan_id and used MAX(transaction_date) to find the most recent transaction per plan (if any).
4. Calculated Inactivity: Used DATEDIFF(CURDATE(), last_transaction_date) to determine how many days had passed since the last transaction. Plans with either a NULL transaction date or a gap of more than 365 days were flagged.
5. Final Filter: Applied a HAVING clause to return only those plans inactive for over one year.

This approach ensures that accounts with no transactions at all are not excluded, which would happen if an INNER JOIN

#### Challenges:
1. Handling Accounts with No Transactions
One of the key challenges encountered was accurately identifying accounts that had no inflow transactions in the last 365 days — including those that have never had a transaction at all. Using an INNER JOIN would have excluded these accounts entirely, which would violate the requirement to flag all inactive accounts, even newly created or dormant ones. were used.
#### ***Solution:***
To overcome this, a LEFT JOIN was used between plans_plan and savings_savingsaccount, allowing inclusion of all active accounts regardless of transaction history. This approach ensures that accounts with NULL values for transaction_date (i.e., no transactions) are still returned. A conditional logic (CASE) was then applied to treat these NULL transaction dates as inactive by default — assigning them a placeholder inactivity period (e.g., 9999) to ensure they're captured in the > 365 days filter.

2. Handling Transaction Status Uncertainty
While analyzing the savings_savingsaccount table, I noticed that it contained various transaction statuses, including failed or ambiguous ones, which raised the question: Should failed or unconfirmed transactions be included when determining account activity?
##### First Approach:
Since the assessment didn't specify filtering by transaction status, I initially considered excluding transactions that didn't have a clear "success" status. To ensure I was only analyzing actual inflows, I applied a filter: confirmed_amount > 0.
##### Re-evaluating the Business Logic:
Upon re-reading the scenario, I realized that the core focus wasn't on validating transactions, but rather on detecting inactivity that is, accounts with no transaction activity (regardless of transaction status or amount).
##### Final Decision:
To align with the intent of the assessment, I removed the confirmed_amount > 0 filter and focused solely on transaction_date. This ensures that I capture all transaction attempts and accurately flag accounts with no inflow activity in the last 365 days — regardless of whether the transaction was marked as successful or failed.






