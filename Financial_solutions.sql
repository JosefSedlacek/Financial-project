/* Connections:
        card.disp_id <----> disp.disp_id
     disp.account_id <----> account.account_id
      disp.client_id <----> client.client_id
     loan.account_id <----> account.account_id
    order.account_id <----> account.account_id
    trans.account_id <----> account.account_id
district.district_id <----> account.district_id
district.district_id <----> client.district_id
*/

-- -----------------------------------------------------------------------------------
/* History of granted loans
Write a query that prepares a summary of the granted loans in the following dimensions:
- year, quarter, month,
- year, quarter,
- year,
- total.
Display the following information as the result of the summary:
- total amount of loans,
- average loan amount,
- total number of given loans
*/

SELECT
    EXTRACT(YEAR FROM date) AS loan_year,
    EXTRACT(QUARTER FROM date) AS loan_quarter,
    EXTRACT(MONTH FROM date) AS loan_month,
    SUM(payments) AS loans_sum,
    AVG(payments) AS loans_avg,
    COUNT(payments) AS loans_count
FROM loan
GROUP BY 1, 2, 3 WITH ROLLUP
ORDER BY 1, 2, 3;

-- -----------------------------------------------------------------------------------
 /* Loan status
On the database site, we can find information that there are a total of 682
granted loans in the database, of which 606 have been repaid and 76 have not.
Let's assume that we don't have information about which status corresponds to a repaid
loan and which does not. In this situation, we need to infer this information from the data.
To do this, write a query to help you answer the question of which
statuses represent repaid loans and which represent unpaid loans.
*/
SELECT COUNT(*) FROM loan; -- total is 682

SELECT
    status,
    COUNT(status) AS loans_count
FROM loan
GROUP BY 1; -- A and C must be paid loans

-- Check if A + C is actually 606
-- Check if B + D is 76
SELECT
    SUM(CASE WHEN status IN ('A', 'C') THEN loans_count ELSE 0 END) AS sum_ac,
    SUM(CASE WHEN status IN ('B', 'D') THEN loans_count ELSE 0 END) AS sum_bd
FROM (
    SELECT
        status,
        COUNT(status) AS loans_count
    FROM loan
    GROUP BY status
) cte_status; -- sum_ac = 606   and   sum_bd = 76


-- -----------------------------------------------------------------------------------
/* Analysis of accounts
Write a query that ranks accounts according to the following criteria:
- number of given loans (decreasing),
- amount of given loans (decreasing),
- average loan amount,
Only fully paid loans are considered.
*/
SELECT
    account_id,
    COUNT(amount) AS loans_count,
    SUM(amount) AS loans_sum,
    AVG(amount) AS loans_avg
FROM loan
WHERE status IN ('A', 'C')
GROUP BY account_id
ORDER BY 3 DESC; -- loans_count is always 1

SELECT
    account_id,
    SUM(amount) AS loans_sum,
    AVG(amount) AS loans_avg,
    ROW_NUMBER() OVER (ORDER BY SUM(amount) DESC) AS account_rank
FROM loan
WHERE status IN ('A', 'C')
GROUP BY account_id
ORDER BY loans_sum DESC, loans_avg DESC;

-- -----------------------------------------------------------------------------------
/* Fully paid loans - genders
Find out the balance of repaid loans, divided by client gender.
Additionally, use a method of your choice to check whether the query is correct.
*/
SELECT
    c.gender,
    sum(l.amount) AS amount
FROM loan AS l
LEFT JOIN account AS a USING (account_id)
LEFT JOIN disp AS d USING (account_id)
LEFT JOIN client AS c USING (client_id)
WHERE l.status IN ('A', 'C')
GROUP BY c.gender;

-- Verify if it is correct:
DROP TABLE IF EXISTS verify_table;

CREATE TEMPORARY TABLE verify_table AS
SELECT
    c.gender,
    sum(l.amount) AS amount
FROM loan AS l
LEFT JOIN account AS a USING (account_id)
LEFT JOIN disp AS d USING (account_id)
LEFT JOIN client AS c USING (client_id)
WHERE l.status IN ('A', 'C')
GROUP BY c.gender;

WITH cte AS (
    SELECT SUM(amount) AS amount
    FROM loan AS l
    WHERE l.status IN ("A", "C")
)
SELECT (
    (SELECT SUM(amount) FROM verify_table) - (SELECT amount FROM cte)
    ); -- result is not 0 so there must be mistake

-- RIGHT SOLUTION -------------------
-- Fixing disponent and owner problem:
SELECT
    c.gender,
    sum(l.amount) AS amount
FROM loan AS l
LEFT JOIN account AS a USING (account_id)
LEFT JOIN disp AS d USING (account_id)
LEFT JOIN client AS c USING (client_id)
WHERE
    l.status IN ('A', 'C')
    AND d.type = "OWNER"
GROUP BY c.gender;
-- ------------------------------------

-- verify:
DROP TABLE IF EXISTS verify_table;

CREATE TEMPORARY TABLE verify_table AS
SELECT
    c.gender,
    sum(l.amount) AS amount
FROM loan AS l
LEFT JOIN account AS a USING (account_id)
LEFT JOIN disp AS d USING (account_id)
LEFT JOIN client AS c USING (client_id)
WHERE
    l.status IN ('A', 'C')
    AND d.type = "OWNER"
GROUP BY c.gender;

WITH cte AS (
    SELECT SUM(amount) AS amount
    FROM loan AS l
    WHERE l.status IN ("A", "C")
)
SELECT (
    (SELECT SUM(amount) FROM verify_table) - (SELECT amount FROM cte)
    ); -- correct

-- -----------------------------------------------------------------------------------
/* Client analysis - part 1
Modifying the queries from the exercise on paid loans, answer the following questions:
- Who has more repaid loans - women or men?
- What is the average age of the borrower divided by gender?
*/
DROP TABLE IF EXISTS joined_tables;
-- Create table - I will work with it in next steps
CREATE TEMPORARY TABLE joined_tables AS
SELECT
    c.client_id,
    l.loan_id,
    l.amount,
    l.status,
    l.payments,
    c.gender,
    c.birth_date,
    c.district_id AS client_district,
    d.account_id,
    d.type,
    dst.district_id AS district
FROM loan AS l
LEFT JOIN account AS a USING (account_id)
LEFT JOIN disp AS d USING (account_id)
LEFT JOIN client AS c USING (client_id)
LEFT JOIN district AS dst ON c.district_id = dst.district_id
WHERE
    l.status IN ('A', 'C')
    AND d.type = "OWNER";

SELECT * FROM joined_tables;

DROP TABLE IF EXISTS client_analysis;
CREATE TEMPORARY TABLE client_analysis AS
SELECT
    gender,
    2024 - EXTRACT(YEAR FROM birth_date) AS client_age,
    SUM(amount) AS loans_amount,
    COUNT(client_id) AS count_ids
FROM joined_tables
GROUP BY gender, birth_date;

SELECT * FROM client_analysis;

SELECT
    gender,
    SUM(count_ids) AS count_ids
FROM client_analysis
GROUP BY gender;
-- Males:   299
-- Females: 307

SELECT
    gender,
    AVG(client_age) AS avg_age
FROM client_analysis
GROUP BY gender;
-- Males:   66.7055
-- Females: 64.8967

-- -----------------------------------------------------------------------------------
/* Client analysis - part 2
Make analyses that answer the questions:
- which area has the most clients,
- in which area the highest number of loans was paid,
- in which area the highest amount of loans was paid,
Select only owners of accounts as clients.
*/
SELECT
    district,
    SUM(amount) AS amount_of_given_loans,
    COUNT(DISTINCT client_id) AS count_of_clients,
    COUNT(DISTINCT loan_id) AS count_of_loans
FROM joined_tables
GROUP BY district
ORDER BY count_of_clients DESC
-- Most clients are from these districts: 1, 70, 54, 74, 64, ...

SELECT
    district,
    SUM(amount) AS amount_of_given_loans,
    COUNT(DISTINCT client_id) AS count_of_clients,
    COUNT(DISTINCT loan_id) AS count_of_loans
FROM joined_tables
GROUP BY district
ORDER BY count_of_loans DESC
-- In which area the highest number of loans was paid: 1, 70, 54, 74, ...

SELECT
    district,
    SUM(amount) AS amount_of_given_loans,
    COUNT(DISTINCT client_id) AS count_of_clients,
    COUNT(DISTINCT loan_id) AS count_of_loans
FROM joined_tables
GROUP BY district
ORDER BY amount_of_given_loans DESC;
-- In which area the highest amount of loans was paid: 1, 74, 54, 64, 70, ...

/* Client analysis - part 3
Use the query created in the previous task and modify it to
determine the percentage of each district in the total amount of loans granted.
*/
WITH cte AS (
    SELECT
        district,
        SUM(amount) AS amount_of_given_loans,
        COUNT(DISTINCT client_id) AS count_of_clients,
        COUNT(DISTINCT loan_id) AS count_of_loans
    FROM joined_tables
    GROUP BY district
    ORDER BY amount_of_given_loans DESC
)
SELECT
    *,
    amount_of_given_loans / SUM(amount_of_given_loans) OVER () AS share
FROM cte;

/* Client selection - part 1
Check the database for the clients who meet the following results:
- their account balance is above 1000,
- they have more than five loans,
- they were born after 1990.
And we assume that the account balance is loan amount - payments.
*/
SELECT
    client_id,
    SUM(amount - payments) AS client_balance,
    COUNT(loan_id) AS loans_amount
FROM joined_tables
GROUP BY client_id
HAVING
    client_balance > 1000
    AND loans_amount > 5;

/* Client selection - part 2
From the previous exercise you probably already know that there are
no customers who meet the requirements. Make an analysis to determine
which condition caused the empty results.
 */
SELECT
    client_id,
    SUM(amount - payments) AS client_balance,
    COUNT(loan_id) AS loans_amount
FROM joined_tables
GROUP BY client_id
HAVING
    client_balance > 1000
    -- AND loans_amount > 5
ORDER BY loans_amount; -- there is maximum of 1 loan_amount

/* Expiring cards
Write a procedure to refresh the table you created (you can call it e.g. cards_at_expiration) containing the following columns:
- client id,
- card id,
- expiration date - assume that the card can be active for 3 years after issue date,
- client address (column A3 is enough).
*/
SELECT *
FROM card;

SELECT
    client.client_id,
    card.card_id,
    DATE_ADD(card.issued, INTERVAL 3 YEAR) AS expiration_date,
    district.A3 AS client_adress
FROM card
LEFT JOIN disp USING (disp_id)
LEFT JOIN client USING (client_id)
LEFT JOIN district USING (district_id);

WITH cte AS (
    SELECT
        client.client_id,
        card.card_id,
        DATE_ADD(card.issued, INTERVAL 3 YEAR) AS expiration_date,
        district.A3 AS client_adress
    FROM card
    LEFT JOIN disp USING (disp_id)
    LEFT JOIN client USING (client_id)
    LEFT JOIN district USING (district_id)
)
SELECT *
FROM cte
WHERE '2000-01-01' BETWEEN DATE_ADD(expiration_date, INTERVAL -7 DAY) AND expiration_date;

CREATE TABLE cards_at_expiration
(client_id   INT   NOT NULL,
 card_id   INT DEFAULT 0   NOT NULL,
 expiration_date   DATE   NULL,
 A3   VARCHAR(15) CHARSET utf8   NOT NULL,
 generated_for_date   DATE   NULL);

-- Add parameter p_date

WITH cte AS (SELECT client.client_id,
                    card.card_id,
                    DATE_ADD(card.issued, INTERVAL 3 YEAR) AS expiration_date,
                    district.A3 AS client_adress
             FROM card
                      LEFT JOIN disp USING (disp_id)
                      LEFT JOIN client USING (client_id)
                      LEFT JOIN district USING (district_id))
SELECT *
FROM cte
WHERE p_date BETWEEN DATE_ADD(expiration_date, INTERVAL -7 DAY) AND expiration_date;

DELIMITER $$
DROP PROCEDURE IF EXISTS financial10_91.generate_cards_at_expiration_report;
CREATE PROCEDURE financial10_91.generate_cards_at_expiration_report(p_date DATE)
BEGIN
END;
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS financial10_91.generate_cards_at_expiration_report;
CREATE PROCEDURE financial10_91.generate_cards_at_expiration_report(p_date DATE)
BEGIN
    TRUNCATE TABLE financial10_91.cards_at_expiration;
    INSERT INTO financial10_91.cards_at_expiration
    WITH cte AS (
        SELECT
            client.client_id,
            card.card_id,
            DATE_ADD(card.issued, INTERVAL 3 YEAR) AS expiration_date,
            district.A3                            AS client_adress
        FROM card
        LEFT JOIN disp USING (disp_id)
        LEFT JOIN client USING (client_id)
        LEFT JOIN district USING (district_id))
    SELECT
        *,
        p_date
    FROM cte
    WHERE p_date BETWEEN DATE_ADD(expiration_date, INTERVAL -7 DAY) AND expiration_date;
END;
DELIMITER ;

CALL financial10_91.generate_cards_at_expiration_report('2001-01-01');
SELECT * FROM financial10_91.cards_at_expiration;
