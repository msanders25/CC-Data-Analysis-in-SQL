-- Credit Card Data Analysis
-- https://www.kaggle.com/datasets/ananta/credit-card-data?select=CreditCardData.xlsx

-- 1) First high level join to view combined data.
SELECT 
    transaction_id, 
    transaction_value, 
    `month`, 
    transaction_date, 
    card_number, 
    card_family, 
    credit_limit, 
    card_base.cust_id, 
    age,
    age_group, 
    customer_segment
FROM transactions
JOIN card_base
    ON transactions.credit_card_id = card_base.card_number
JOIN customers
    ON card_base.cust_id = customers.cust_id
ORDER BY 4;

-- 2) Average transaction value by card family.
WITH cc_data AS
(
SELECT 
    transaction_id,
    transaction_value, 
    card_family,  
    card_base.cust_id
FROM transactions
JOIN card_base
    ON transactions.credit_card_id = card_base.card_number
JOIN customers
    ON card_base.cust_id = customers.cust_id
ORDER BY 4
)
SELECT 
    card_family, 
    COUNT(*) AS num_of_transactions, 
    ROUND(AVG(transaction_value), 0) AS avg_transaction_value
FROM cc_data
GROUP BY card_family
ORDER BY 3 DESC;

-- 3) Average transaction value by customer segment.
WITH cc_data AS
(
SELECT 
    transaction_id, 
    transaction_value, 
    card_base.cust_id, 
    customer_segment
FROM transactions
JOIN card_base
    ON transactions.credit_card_id = card_base.card_number
JOIN customers
    ON card_base.cust_id = customers.cust_id
ORDER BY 4
)
SELECT 
    customer_segment, 
    COUNT(*) AS num_of_transactions, 
    ROUND(avg(transaction_value), 0) AS avg_transaction_value
FROM cc_data
GROUP BY customer_segment
ORDER BY 3 DESC;

-- 4) Average transaction value by month.
WITH cc_data AS
(
SELECT 
    transaction_id, 
    transaction_value, 
    `month`, 
    card_base.cust_id 
FROM transactions
JOIN card_base
    ON transactions.credit_card_id = card_base.card_number
JOIN customers
    ON card_base.cust_id = customers.cust_id
ORDER BY 4
)
SELECT 
    `month`, 
    COUNT(*) AS num_of_transactions, 
    ROUND(avg(transaction_value), 0) AS avg_transaction_value
FROM cc_data
GROUP BY `month`
ORDER BY 3 DESC;

-- 5) Average transaction value by age group.
WITH cc_data AS
(
SELECT 
    transaction_id, 
    transaction_value,  
    card_base.cust_id, 
    age_group
FROM transactions
JOIN card_base
    ON transactions.credit_card_id = card_base.card_number
JOIN customers
    ON card_base.cust_id = customers.cust_id
ORDER BY 4
)
SELECT 
    age_group, 
    COUNT(*) AS num_of_transactions, 
    ROUND(AVG(transaction_value), 0) AS avg_transaction_value
FROM cc_data
GROUP BY age_group
ORDER BY 3 DESC;

-- 6) Average transaction value by customer segment by age group.
WITH cc_data AS
(
SELECT 
    transaction_id, 
    transaction_value, 
    card_base.cust_id, 
    age_group, 
    customer_segment
FROM transactions
JOIN card_base
    ON transactions.credit_card_id = card_base.card_number
JOIN customers
    ON card_base.cust_id = customers.cust_id
ORDER BY 4
)
SELECT 
    customer_segment, 
    age_group,
    COUNT(*) AS num_of_transactions, 
    ROUND(AVG(transaction_value), 0) AS avg_transaction_value
FROM cc_data
GROUP BY customer_segment, age_group
ORDER BY 1;

-- 7) Running 7 day average of daily average transaction value.
SELECT *, 
    ROUND(AVG(daily_avg_tvalue) OVER (PARTITION BY WEEK(transaction_date) ORDER BY transaction_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 0) AS running_7_day_avg, 
    WEEK(transaction_date) AS week_number
FROM
(
    SELECT 
	transaction_date, 
        ROUND(AVG(transaction_value), 0) AS daily_avg_tvalue
    FROM transactions
    GROUP BY transaction_date
    ORDER BY 1
) 
AS subq;

-- 8) Running monthly average by day of daily average transaction value.
SELECT *, 
    ROUND(AVG(daily_avg_tvalue) OVER (PARTITION BY `month` ORDER BY transaction_date), 0) AS running_month_avg
FROM
(
    SELECT 
	transaction_date, 
	ROUND(AVG(transaction_value), 0) AS daily_avg_tvalue,
        `month`
    FROM transactions
    GROUP BY transaction_date, `month`
    ORDER BY 1
) 
AS subq
ORDER BY 1;

-- 9) Top 5 paying customers by month.
WITH top5 AS
(
SELECT 
    cust_id, 
    `month`, 
    SUM(transaction_value) AS total_spent
FROM
(
    SELECT 
	transaction_value, 
	`month`, 
	card_base.cust_id, 
	card_family,
	age,
	age_group, 
	customer_segment
    FROM transactions
    JOIN card_base
	ON transactions.credit_card_id = card_base.card_number
    JOIN customers
	ON card_base.cust_id = customers.cust_id
) AS subq
GROUP BY cust_id, `month`
ORDER BY 1
)
SELECT *
FROM 
(
    SELECT *, DENSE_RANK() OVER (PARTITION BY `month` ORDER BY total_spent DESC) AS ranking
    FROM top5
) AS subq
WHERE ranking <= 5
ORDER BY case `month`
	    WHEN 'Jan' THEN 1
            WHEN 'Feb' THEN 2
            WHEN 'Mar' THEN 3
            WHEN 'Apr' THEN 4
            WHEN 'May' THEN 5
            WHEN 'Jun' THEN 6
            WHEN 'Jul' THEN 7 
            WHEN 'Aug' THEN 8
            WHEN 'Sep' THEN 9
            WHEN 'Oct' THEN 10
            WHEN 'Nov' THEN 11
            WHEN 'Dec' THEN 12
	END,
        total_spent DESC;
        
-- 10) Customer count and average transaction value by customer segment by age group.
WITH ccholders AS
(
SELECT 
    COUNT(*) AS customer_count, 
    ROUND(AVG(transaction_value), 0) AS avg_tvalue, 
    customer_segment, 
    age_group
FROM transactions
JOIN card_base
    ON transactions.credit_card_id = card_base.card_number
JOIN customers
    ON card_base.cust_id = customers.cust_id
GROUP BY customer_segment, age_group
ORDER BY 3 
)
SELECT *, DENSE_RANK() OVER (PARTITION BY customer_segment ORDER BY customer_count DESC) AS ranking
FROM ccholders;

-- 11) Count the number of transactions not flagged as fraudulent.
SELECT COUNT(*)
FROM transactions
LEFT JOIN fraud_base
    ON transactions.transaction_id = fraud_base.transaction_id
WHERE fraud_flag IS NULL;

-- 12) Number of fraud transactions, sum of fraud transaction value, and average fraud transaction value by month.
WITH tfraud AS
(
SELECT 
    customers.cust_id,
    age_group,
    customer_segment,
    card_family,
    transactions.transaction_id,
    transaction_value,
    `month`,
    fraud_flag
FROM customers
JOIN card_base
    ON customers.cust_id = card_base.cust_id
JOIN transactions
    ON card_base.card_number = transactions.credit_card_id
JOIN fraud_base
    ON transactions.transaction_id = fraud_base.transaction_id
)
SELECT 
    `month`, 
    COUNT(*) AS num_transactions, 
    SUM(transaction_value) AS total_spent, 
    ROUND(AVG(transaction_value), 0) AS avg_tvalue
FROM tfraud
GROUP BY `month`
ORDER BY CASE `month`
	    WHEN 'Jan' THEN 1
            WHEN 'Feb' THEN 2
            WHEN 'Mar' THEN 3
            WHEN 'Apr' THEN 4
            WHEN 'May' THEN 5
            WHEN 'Jun' THEN 6
            WHEN 'Jul' THEN 7 
            WHEN 'Aug' THEN 8
            WHEN 'Sep' THEN 9
            WHEN 'Oct' THEN 10
            WHEN 'Nov' THEN 11
            WHEN 'Dec' THEN 12
	END;

-- 13) Number of fraud transactions, sum of fraud transaction value, and average fraud transaction value by card family.
WITH tfraud AS
(
SELECT 
    customers.cust_id,
    age_group,
    customer_segment,
    card_family,
    transactions.transaction_id,
    transaction_value,
    `month`,
    fraud_flag
FROM customers
JOIN card_base
    ON customers.cust_id = card_base.cust_id
JOIN transactions
    ON card_base.card_number = transactions.credit_card_id
JOIN fraud_base
    ON transactions.transaction_id = fraud_base.transaction_id
)
SELECT 
    card_family, 
    COUNT(*) AS num_transactions, 
    SUM(transaction_value) AS total_spent, 
    ROUND(AVG(transaction_value), 0) AS avg_tvalue
FROM tfraud
GROUP BY card_family
ORDER BY 2 DESC;

-- 14) Number of fraud transactions, sum of fraud transaction value, and average fraud transaction value by customer segment.
WITH tfraud AS
(
SELECT 
    customers.cust_id,
    age_group,
    customer_segment,
    card_family,
    transactions.transaction_id,
    transaction_value,
    `month`,
    fraud_flag
FROM customers
JOIN card_base
    ON customers.cust_id = card_base.cust_id
JOIN transactions
    ON card_base.card_number = transactions.credit_card_id
JOIN fraud_base
    ON transactions.transaction_id = fraud_base.transaction_id
)
SELECT 
    customer_segment, 
    COUNT(*) AS num_transactions, 
    SUM(transaction_value) AS total_spent, 
    ROUND(AVG(transaction_value), 0) AS avg_tvalue
FROM tfraud
GROUP BY customer_segment
ORDER BY 2 DESC;

-- 15) Number of fraud transactions, sum of fraud transaction value, and average fraud transaction value by age group.
WITH tfraud AS
(
SELECT 
    customers.cust_id,
    age_group,
    customer_segment,
    card_family,
    transactions.transaction_id,
    transaction_value,
    `month`,
    fraud_flag
FROM customers
JOIN card_base
    ON customers.cust_id = card_base.cust_id
JOIN transactions
    ON card_base.card_number = transactions.credit_card_id
JOIN fraud_base
    ON transactions.transaction_id = fraud_base.transaction_id
)
SELECT 
    age_group, 
    COUNT(*) AS num_transactions, 
    SUM(transaction_value) AS total_spent, 
    ROUND(AVG(transaction_value), 0) AS avg_tvalue
FROM tfraud
GROUP BY age_group
ORDER BY 2 DESC;
