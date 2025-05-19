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
Calculates total deposits per customer and ranks results in descending order of deposit amount (ORDER BY total_deposit DESC). The deposit was converted from kobo to Naira as it is a way presentable way of showing financial numbers.

#### Challenges
1. Overcounting Deposits
Initially, joining on owner_id would have included all deposits made by the customer across different plans, which didn't separate savings from investments.
#### ***Solution:*** Join using plan_id to ensure deposits are grouped correctly under the right plan type (savings vs. investment)


## Assessment Q2 - Transaction Frequency Analysis
#### Approach: 
To segment customers by transaction frequency, I followed these steps:
1. Join Users and Transactions: Joined the users_customuser table with the savings_savingsaccount table to link customers with their transactions.
2. Calculate Monthly Frequency: For each customer, I calculated the number of distinct transactions divided by the number of active months (based on distinct YYYY-MM from transaction_date), giving the average transactions per month.
3. Categorize Frequency: Based on the computed average, I categorized each customer as required.
4. Aggregate by Category: Finally, I grouped customers by frequency category and calculated the count of customers and the average transaction frequency per group.


#### Challenges
1. Handling Cases With No Transactions (Null transaction date): Customers with no transaction date were leading to NULL or division by zero and thereby distorting the freq_count_permonth.
##### ***Solution:*** Exclude NULL transaction date to only calculate frequency based on actual activity. This prevents inflated ratios and ensures accurate customer categorization and also used NULLIF() on the month count to prevent division by zero and exclude invalid entries.

2. Multiple Transactions on Same Day
There was concern about inflated counts due to multiple transactions on the same day.
#### ***Solution:*** Used transaction_reference to count distinct transactions, assuming it's a reliable unique identifier.

3. Ambiguity Around Timeframe
The question didn’t specify a fixed date range (e.g., last 6 months or last year).
#### ***Approach:*** Used all available transaction history for each customer to calculate frequency, assuming a long-term view was acceptable.



## Assessment Q3 - Account Inactivity Alert
#### Approach:
To identify active accounts (either savings or investments) with no inflow transactions for over one year, I performed the following steps:
1. Filtered Active Accounts: From the plans_plan table, I filtered for only savings or investment plans using the flags is_regular_savings or is_a_fund.
2. Joined with Transactions: I used a LEFT JOIN with the savings_savingsaccount table to include both active plans with transactions and those without any transaction history.
3. Determined Last Transaction: For each account, I retrieved the most recent transaction_date using MAX().
4. Handled Nulls: To ensure accounts with no transactions were still evaluated, I applied COALESCE() to default null transaction_date values to a very old date.
6. Calculated Inactivity: I computed inactivity_days as the number of days since the last transaction.
7. Filtered Inactive Accounts: Finally, I selected only those accounts with more than 365 days of inactivity.
This approach ensures even completely inactive accounts (with no transaction history at all) are appropriately flagged.

#### Challenges:
1. Handling Accounts with No Transactions
One of the key challenges encountered was accurately identifying accounts that had no inflow transactions in the last 365 days — including those that have never had a transaction at all. Using an INNER JOIN would have excluded these accounts entirely, which would violate the requirement to flag all inactive accounts, even newly created or dormant ones. Also accounts with no transactions were excluded from the result because MAX(transaction_date) returns NULL, and DATEDIFF() with a null value results in null as well
#### ***Solution:*** To overcome this, a LEFT JOIN was used between plans_plan and savings_savingsaccount, allowing inclusion of all active accounts regardless of transaction history. This approach ensures that accounts with NULL values for transaction_date (i.e., no transactions) are still returned. I used COALESCE(MAX(transaction_date), '1900-01-01') to convert nulls into a fixed past date, ensuring such accounts are included and flagged.


2. Handling Transaction Status Uncertainty
While analyzing the savings_savingsaccount table, I noticed that it contained various transaction statuses, including failed or ambiguous ones, which raised the question: Should failed or unconfirmed transactions be included when determining account activity?
##### First Approach:
Since the assessment didn't specify filtering by transaction status, I initially considered excluding transactions that didn't have a clear "success" status. To ensure I was only analyzing actual inflows, I applied a filter: confirmed_amount > 0.
##### Re-evaluating the Business Logic:
Upon re-reading the scenario, I realized that the core focus wasn't on validating transactions, but rather on detecting inactivity that is, accounts with no transaction activity (regardless of transaction status or amount).
##### Final Decision: To align with the intent of the assessment, I removed the confirmed_amount > 0 filter and focused solely on transaction_date. This ensures that I capture all transaction attempts and accurately flag accounts with no inflow activity in the last 365 days — regardless of whether the transaction was marked as successful or failed.

3. Type Identification from Boolean Flags
The dataset had two boolean flags (is_a_fund and is_regular_savings) but no unified account type field.
#### ***Approach:*** I used a CASE statement to derive the account type (Investment or Savings) for reporting clarity, and expected output format.




## Assessment Q4 - Customer Lifetime Value (CLV) Estimation
#### Aproach
1. Account Tenure: I measured the number of months each customer has been active by calculating the difference between the current date and their account creation date (created_on).
2. Aggregate Transaction Data: I counted the total number of transactions per customer from the savings transactions table and summed the total transaction value (confirmed_amount) per customer to capture their overall transaction volume.
3. Calculate Average Profit per Transaction: I assumed a profit margin of 0.1% per transaction(as per the assessment), so I computed the average profit per transaction by multiplying the total transaction value by 0.001 and dividing by the total number of transactions.
4. Estimated CLV: I calculated the CLV using the assumption provided: 
   
   ```math
   \text{CLV} = \left(\frac{\text{Total Transactions}}{\text{Tenure}}\right) \times 12 \times \text{Avg Profit per Transaction}
I divided the final estimated_CLV by 100 to convert to Naira.

#### Challenges
Identifying the Correct Date for Tenure Calculation While calculating account tenure, I noticed two fields in the dataset: date_joined and created_on. To ensure accuracy, I checked whether these dates were identical or if one better represented the user's actual account start date.

#### ***Solution:*** I ran a query to compare the two dates to check for discrepancies. I settled on using date_joined.





