---------------------------------------------------------------------------------------------
-- Type of relationship ---------------------------------------------------------------------
USE financial;

SELECT
    account_id,
    count(trans_id) as amount
FROM trans
GROUP BY account_id
ORDER BY 2 DESC

---------------------------------------------------------------------------------------------
-- History of granted loans -----------------------------------------------------------------
SELECT *
FROM financial.loan;

SELECT
    extract(YEAR FROM date) as loan_year,
    extract(QUARTER FROM date) as loan_quarter,
    extract(MONTH FROM date) as loan_month,
FROM financial.loan;

SELECT
    extract(YEAR FROM date) as loan_year,
    extract(QUARTER FROM date) as loan_quarter,
    extract(MONTH FROM date) as loan_month,
FROM financial.loan
GROUP BY 1, 2, 3;

SELECT
    extract(YEAR FROM date) as loan_year,
    extract(QUARTER FROM date) as loan_quarter,
    extract(MONTH FROM date) as loan_month,
FROM financial.loan
GROUP BY 1, 2, 3 WITH ROLLUP;

SELECT
    extract(YEAR FROM date) as loan_year,
    extract(QUARTER FROM date) as loan_quarter,
    extract(MONTH FROM date) as loan_month,
    sum(payments) as loans_total,
    avg(payments) as loans_avg,
    count(payments) as loans_count
FROM financial.loan
GROUP BY 1, 2, 3 WITH ROLLUP
ORDER BY 1, 2, 3;

---------------------------------------------------------------------------------------------
-- Loan status ------------------------------------------------------------------------------
SELECT count(*) FROM financial.loan;

SELECT 
    status, 
    count(status) 
FROM financial.loan
GROUP BY 1
ORDER BY 1;

---------------------------------------------------------------------------------------------
-- Analysis of accounts ---------------------------------------------------------------------
SELECT *
FROM financial.loan
WHERE status IN ('A', 'C');

SELECT 
    account_id
FROM financial.loan
WHERE status IN ('A', 'C');

SELECT
    account_id,
    sum(amount)   as loans_amount,
    count(amount) as loans_count,
    avg(amount)   as loans_avg
FROM financial.loan
WHERE status IN ('A', 'C')
GROUP BY account_id;

WITH cte as (
    SELECT
        account_id,
        sum(amount)   as loans_amount,
        count(amount) as loans_count,
        avg(amount)   as loans_avg
    FROM financial.loan
    WHERE status IN ('A', 'C')
    GROUP BY account_id
)
SELECT *
FROM cte;

WITH cte AS (
    SELECT
       account_id,
       sum(amount)   as loans_amount,
       count(amount) as loans_count,
       avg(amount)   as loans_avg
    FROM financial.loan
    WHERE status IN ('A', 'C')
    GROUP BY account_id
)
SELECT
    *,
    ROW_NUMBER() over (ORDER BY loans_amount DESC) AS rank_loans_amount,
    ROW_NUMBER() over (ORDER BY loans_count DESC) AS rank_loans_count
FROM cte;

---------------------------------------------------------------------------------------------
-- Fully paid loans -------------------------------------------------------------------------
SELECT *
FROM financial.loan as l
WHERE l.status IN ('A', 'C');

SELECT *
FROM
        financial.loan as l
    INNER JOIN
        financial.account as a USING (account_id)
WHERE l.status IN ('A', 'C');

SELECT *
FROM
        financial.loan as l
    INNER JOIN
        financial.account as a USING (account_id)
    INNER JOIN
        financial.disp as d USING (account_id)
WHERE l.status IN ('A', 'C');

SELECT
    *
FROM
        financial.loan as l
    INNER JOIN
        financial.account a using (account_id)
    INNER JOIN
        financial.disp as d using (account_id)
    INNER JOIN
        financial.client as c using (client_id)
WHERE l.status IN ('A', 'C');

SELECT
    c.gender,
    sum(l.amount) as amount
FROM
        financial.loan as l
    INNER JOIN
        financial.account a using (account_id)
    INNER JOIN
        financial.disp as d using (account_id)
    INNER JOIN
        financial.client as c using (client_id)
WHERE l.status IN ('A', 'C')
GROUP BY c.gender;

DROP TABLE IF EXISTS tmp_results;
CREATE TEMPORARY TABLE tmp_results AS
SELECT
    c.gender,
    sum(l.amount) as amount
FROM
        financial.loan as l
    INNER JOIN
        financial.account a using (account_id)
    INNER JOIN
        financial.disp as d using (account_id)
    INNER JOIN
        financial.client as c using (client_id)
WHERE l.status IN ('A', 'C')
GROUP BY c.gender;

WITH cte as (
    SELECT sum(amount) as amount
    FROM financial.loan as l
    WHERE l.status IN ('A', 'C')    
)
SELECT (SELECT SUM(amount) FROM tmp_results) - (SELECT amount FROM cte);

DROP TABLE IF EXISTS tmp_results;
CREATE TEMPORARY TABLE tmp_results AS
SELECT
    c.gender,
    sum(l.amount) as amount
FROM
        financial.loan as l
    INNER JOIN
        financial.account a using (account_id)
    INNER JOIN
        financial.disp as d using (account_id)
    INNER JOIN
        financial.client as c using (client_id)
WHERE True
    AND l.status IN ('A', 'C')
    AND d.type = 'OWNER'
GROUP BY c.gender;

WITH cte as (
    SELECT sum(amount) as amount
    FROM financial.loan as l
    WHERE l.status IN ('A', 'C')    
)
SELECT (SELECT SUM(amount) FROM tmp_results) - (SELECT amount FROM cte);

---------------------------------------------------------------------------------------------
-- Client analysis --------------------------------------------------------------------------
SELECT
    c.gender,
    sum(l.amount) as amount
FROM
        financial.loan as l
    INNER JOIN
        financial.account a using (account_id)
    INNER JOIN
        financial.disp as d using (account_id)
    INNER JOIN
        financial.client as c using (client_id)
WHERE True
    AND l.status IN ('A', 'C')
    AND d.type = 'OWNER'
GROUP BY c.gender;

SELECT
    c.gender,
    2024 - extract(year from birth_date) as age,
    sum(l.amount) as amount
FROM
        financial.loan as l
    INNER JOIN
        financial.account a using (account_id)
    INNER JOIN
        financial.disp as d using (account_id)
    INNER JOIN
        financial.client as c using (client_id)
WHERE True
    AND l.status IN ('A', 'C')
    AND d.type = 'OWNER'
GROUP BY c.gender, 2;

SELECT
    c.gender,
    2024 - extract(year from birth_date) as age,

    -- aggregates
    sum(l.amount) as loans_amount,
    count(l.amount) as loans_count
FROM
        financial.loan as l
    INNER JOIN
        financial.account a using (account_id)
    INNER JOIN
        financial.disp as d using (account_id)
    INNER JOIN
        financial.client as c using (client_id)
WHERE True 
    AND l.status IN ('A', 'C')
    AND d.type = 'OWNER'
GROUP BY c.gender, 2;

DROP TABLE IF EXISTS tmp_analysis;
CREATE TEMPORARY TABLE tmp_analysis AS
SELECT
    c.gender,
    2024 - extract(year from birth_date) as age,

    -- aggregates
    sum(l.amount) as loans_amount,
    count(l.amount) as loans_count
FROM
        financial.loan as l
    INNER JOIN
        financial.account a using (account_id)
    INNER JOIN
        financial.disp as d using (account_id)
    INNER JOIN
        financial.client as c using (client_id)
WHERE True 
    AND l.status IN ('A', 'C')
    AND d.type = 'OWNER'
GROUP BY c.gender, 2;

SELECT SUM(loans_count) FROM tmp_analysis;

SELECT
    gender,
    SUM(loans_count) as loans_count
FROM tmp_analysis
GROUP BY gender;

SELECT
    gender,
    avg(age) as avg_age
FROM tmp_analysis
GROUP BY gender;

-- Part 2
SELECT
    c.gender,
    2024 - extract(year from birth_date) as age,
    sum(l.amount) as loans_amount,
    count(l.amount) as loans_count
FROM
        financial.loan as l
    INNER JOIN
        financial.account a using (account_id)
    INNER JOIN
        financial.disp as d using (account_id)
    INNER JOIN
        financial.client as c using (client_id)
WHERE True 
    AND l.status IN ('A', 'C')
    AND d.type = 'OWNER'
GROUP BY c.gender, 2;

SELECT
    sum(l.amount) as loans_amount,
    count(l.amount) as loans_count
FROM
        financial.loan as l
    INNER JOIN
        financial.account a using (account_id)
    INNER JOIN
        financial.disp as d using (account_id)
    INNER JOIN
        financial.client as c using (client_id)
WHERE True 
    AND l.status IN ('A', 'C')
    AND d.type = 'OWNER';

SELECT
    d2.district_id,

    count(distinct c.client_id) as customer_amount,
    sum(l.amount) as loans_given_amount,
    count(l.amount) as loans_given_count
FROM
        financial.loan as l
    INNER JOIN
        financial.account a using (account_id)
    INNER JOIN
        financial.disp as d using (account_id)
    INNER JOIN
        financial.client as c using (client_id)
    INNER JOIN
        financial.district as d2 on
            c.district_id = d2.district_id
WHERE True 
    AND l.status IN ('A', 'C')
    AND d.type = 'OWNER'
GROUP BY d2.district_id;

DROP TABLE IF EXISTS tmp_district_analytics;
CREATE TEMPORARY TABLE tmp_district_analytics AS
SELECT
    d2.district_id,

    count(distinct c.client_id) as customer_amount,
    sum(l.amount) as loans_given_amount,
    count(l.amount) as loans_given_count
FROM
        financial.loan as l
    INNER JOIN
        financial.account a using (account_id)
    INNER JOIN
        financial.disp as d using (account_id)
    INNER JOIN
        financial.client as c using (client_id)
    INNER JOIN
        financial.district as d2 on
            c.district_id = d2.district_id
WHERE True 
    AND l.status IN ('A', 'C')
    AND d.type = 'OWNER'
GROUP BY d2.district_id;


SELECT *
FROM tmp_district_analytics
ORDER BY customer_amount DESC
LIMIT 1

SELECT *
FROM tmp_district_analytics
ORDER BY loans_given_amount DESC
LIMIT 1

SELECT *
FROM tmp_district_analytics
ORDER BY loans_given_count DESC
LIMIT 1


-- Part 3


---------------------------------------------------------------------------------------------
-- Client Selection -------------------------------------------------------------------------






---------------------------------------------------------------------------------------------
-- Expiring cards ---------------------------------------------------------------------------
