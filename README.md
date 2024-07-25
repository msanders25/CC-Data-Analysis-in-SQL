# CC-Data-Analysis-in-SQL

## Project Overview
The purpose of this project was primarily to show the use of various functions in SQL such as CTEs, window functions, subqueries, and joins while also analyzing credit card data. The analysis portion of the project sought to uncover trends such as the average amount spent by customers under different cards, average amount spent in different age groups, top 5 card holders per month who spent the most, age groups with the most fraudulent transactions, and so on. Trends such as these can help card issuers or other interested parties know where to focus their efforts on preventing fraud and also know which types of cards are the most successful for future revenue growth. 

The dataset used for the analysis is a fictitious dummy set containing info in several tables about transaction IDs, transaction values, card numbers, customers, age of customers, transactions flagged for fraud and so on. All the transactions were recorded for the year 2016. The dataset was modified slightly for the purpose of this project to include age groups for analyzing trends by age.

The original data can be found at this link: 
 - *[kaggle.com](https://www.kaggle.com/datasets/ananta/credit-card-data?select=CreditCardData.xlsx)*
 - Author: Anant Prakash Awasthi

Review the SQL script *[HERE](https://github.com/msanders25/Crime-Data-Analysis-in-Python/blob/main/Crime%20Data%20Analysis.ipynb)*

## Insights
The queries written in the script provide info on the following:
- Average transaction value by card family.
- Average transaction value by customer segment.
- Average transaction value by month.
- Average transaction value by age group.
- Average transaction value by customer segment by age group.
- Running 7 day average of daily average transaction value.
- Running monthly average by day of daily average transaction value.
- Top 5 paying customers by month.
- Customer count and average transaction value by customer segment by age group.
- Number of transactions not flagged as fraudulent.
- Number of fraud transactions, sum of fraud transaction value, and average fraud transaction value by month.
- Number of fraud transactions, sum of fraud transaction value, and average fraud transaction value by card family.
- Number of fraud transactions, sum of fraud transaction value, and average fraud transaction value by customer segment.
- Number of fraud transactions, sum of fraud transaction value, and average fraud transaction value by age group.

## Project Challenges and Solutions
While this project presented various challenges, the following were particularly demanding and required additional research to achieve the desired outcomes.

### Challenge 1 - Running Averages
The queries computing the running 7 day average and monthly average were tricky to compose. I wanted to see what the running averages were by day but given that multiple transactions were recorded in each day, the running averages would compute based off the rows of transactions and not the transactions per each day. 

For a solution to this, I realized that to get a better understanding of the average spending per day over 7 day periods and by month, the daily average of all the transactions recorded for each day would have to be calculated. From there, the running averages could be calculated as the running average of daily average spending. I used subqueries to first calculate the daily average transactional value of each day and then was able to create window functions off of the subqueries to compute the running average of all transactions each day.

### Challenge 2 - Top 5 Paying Customers
As part of the analysis, I imagined whichever company or card issuer of the cards may want to know which customers spent the most each month to provide rewards to incentivize spending for other card holders. The query providing this info proved difficult to write to show the ranking of highest spending customer by month. Multiple instances of the query running unsuccessfully occured for failure to recognize calculations in subqueries.

As a solution for this, I created a CTE that contained a subquery as the first portion of the CTE calculating total spent by customer ID by month. After that, I created another subquery as the second portion of the CTE where the subquery calculated the ranking of the highest paying customers by month and then the query off of the subquery would filter the ranking to just show the top 5.

## Methods and Process
The approach I took for this analysis involved three main steps:
- Review the data
- Data cleaning (not shown in script. Modified data types, added columns, modified entries for consistency, etc)
- Analysis

I spent time reviewing the dataset before doing any cleaning to understand what information it contained and how the data was stored. From that point I could decide best how to clean the data to then perform the needed joins to display the info for the insights listed above.

SQL script used to complete this project involved using various functions and features such as:
- subqueries
- window functions
- joins
- CTEs
- case stmts
- group by
- dense_rank()

There were more functions used but the above list is provided as an example.
