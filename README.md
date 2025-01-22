# Financial-project
PKDD'99 Financial dataset - SQL final project

## Introduction
This is the final project of the course SQL - data analyst by CodersLab. Dataset is available on this site: [ČVUT Financial dataset](https://fit.cvut.cz/cs/veda-a-vyzkum/cemu-se-venujeme/projekty/relational). It contains 606 successful and 76 not successful loans along with their information and transactions.

It is worth noting that the database uses real data that has been anonymized in order to be made public. It is a collection of financial information from a Czech bank. The dataset contains data for more than 5,300 clients with about one million transactions. What's more, the bank has also released data for nearly 700 loans granted and about 900 credit cards issued.

## Structure of financial database
Get familiar with the schema of the database and answer the following questions:
1. What are the primary keys in the individual tables?
2. What relationships do particular pairs of tables have?

## History of granted loans
Write a query that prepares a summary of the granted loans in the following dimensions:
- year, quarter, month,
- year, quarter,
- year,
- total.  
Display the following information as the result of the summary:
- total amount of loans,
- average loan amount,
- total number of given loans.

## Loan status
On the database site, we can find information that there are a total of 682 granted loans in the database, of which 606 have been repaid and 76 have not. Let's assume that we don't have information about which status corresponds to a repaid loan and which does not. In this situation, we need to infer this information from the data. To do this, write a query to help you answer the question of which statuses represent repaid loans and which represent unpaid loans.

## Analysis of accounts
Write a query that ranks accounts according to the following criteria:
- number of given loans (decreasing),
- amount of given loans (decreasing),
- average loan amount,
Only fully paid loans are considered.

## Fully paid loans
Find out the balance of repaid loans, divided by client gender. Additionally, use a method of your choice to check whether the query is correct.

## Client analysis
#### Part 1
Modifying the queries from the exercise on repaid loans, answer the following questions:
- Who has more repaid loans - women or men?
- What is the average age of the borrower divided by gender?

#### Part 2
Make analyses that answer the questions:
- which area has the most clients,
- in which area the highest number of loans was paid,
- in which area the highest amount of loans was paid.
Select only owners of accounts as clients.

#### Part 3
Use the query created in the previous task and modify it to determine the percentage of each district in the total amount of loans granted.

## Client selection
#### Part 1
Check the database for the clients who meet the following results:
- their account balance is above 1000,
- they have more than 5 loans,
- they were born after 1990.
And we assume that the account balance is loan amount - payments.

#### Part 2
From the previous exercise you probably already know that there are no customers who meet the requirements. Make an analysis to determine which condition caused the empty results.

## Expiring cards
Write a procedure to refresh the table you created (you can call it e.g. cards_at_expiration) containing the following columns:
- client_id,
- card_id,
- expiration_date - assume that the card can be active for 3 years after issue date,
- client_address (column A3 is enough).

---

## Description of tables
#### Card
The table contains credit card data
  - card_id - id of the card,
  - disp_id - id of the card disponent,
  - type - type of card (classic, gold, etc.),
  - issued - date of card issue.

#### Disp
The table contains information about people assigned to the card. Its name is an abbreviation of the term: disponent, and refers to a person who can also use the card.
  - disp_id - id of the card disponent,
  - client_id - id of the client,
  - account_id - id of the account the card is assigned to,
  - type - type of card management (owner or disponent).

#### Client
The table contains basic client information.
 - client_id - id of the client,
 - gender - gender of the client,
 - birth_date - date of birth of the client,
 - district_id - id of the client's area of residence.

#### District
The table contains the demographics for the area.
  - district_id - id of the district,
  - A2 - name of the district,
  - A3 - region,
  - A4 - number of residents,
  - A5 - number of communities below 499 residents,
  - A6 - number of communities with 500-1999 residents,
  - A7 - number of communities with 2000-9999 residents,
  - A8 - number of communities above 10000 residents,
  - A9 - number of cities,
  - A10 - ratio of urban to rural area residents,
  - A11 - average salary,
  - A12 - unemployment rate in 1995,
  - A13 - unemployment rate in 1996,
  - A14 - number of entrepreneurs per 1000 residents,
  - A15 - number of crimes committed in 1995,
  - A16 - number of crimes committed in 1996

#### Account
The table contains information about accounts.
  - account_id - id of account,
  - district_id - id of the district with the branch that opened the account,
  - frequency - frequency of issuing statements,
  - date - date of opening the account.

#### Trans
The table contains information about transactions
  - trans_id - id of transaction,
  - account_id - id of the account the transaction is assigned to,
  - date - date of transaction,
  - type - debit/credit transaction,
  - operation - type of transaction,
  - amount - amount of transaction,
  - balance - account balance after transaction,
  - k_symbol - characteristics of transaction,
  - bank - transaction partner's bank,
  - account - transaction partner's account.

#### Order
The table contains the characteristics of payment order.
  - order_id - identifier,
  - account_id - id of account,
  - bank_to - id of recipient's bank,
  - account_to - id of recipient's account,
  - amount - transfer amount,
  - k_symbol - payment characteristic

#### Loan
The table contains information about loan status.
  - loan_id - id of loan,
  - account_id - id of loan applicant's account,
  - date - data of giving out loan,
  - amount - amount of loan,
  - duration - duration of loan,
  - payments - amount of monthly repayment,
  - status - loan repayment status.
