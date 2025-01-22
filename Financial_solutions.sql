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

WITH cte AS (
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
    GROUP BY d2.district_id
    ;
)
SELECT *
FROM cte;

WITH cte AS (
    SELECT d2.district_id,

           count(distinct c.client_id) as customer_amount,
           sum(l.amount)               as loans_given_amount,
           count(l.amount)             as loans_given_count
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
    GROUP BY d2.district_id
)
SELECT
    *,
    loans_given_amount / SUM(loans_given_amount) OVER () AS share
FROM cte
ORDER BY share DESC;

---------------------------------------------------------------------------------------------
-- Client Selection -------------------------------------------------------------------------
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

SELECT
    c.client_id,

    sum(amount - payments) as client_balance,
    count(loan_id) as loans_amount
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
    AND EXTRACT(YEAR FROM c.birth_date) > 1990
GROUP BY c.client_id;

SELECT
    c.client_id,

    sum(amount - payments) as client_balance,
    count(loan_id) as loans_amount
FROM loan as l
         INNER JOIN
     account a using (account_id)
         INNER JOIN
     disp as d using (account_id)
         INNER JOIN
     client as c using (client_id)
WHERE True
  AND l.status IN ('A', 'C')
  AND d.type = 'OWNER'
GROUP BY c.client_id
HAVING
    SUM(amount - payments) > 1000
    AND COUNT(loan_id) > 5;


-- Part 2
AND EXTRACT(YEAR FROM c.birth_date) > 1990 -- for WHERE
AND count(loan_id) > 5 -- for HAVING

SELECT
    c.client_id,

    sum(amount - payments) as client_balance,
    count(loan_id) as loans_amount
FROM loan as l
         INNER JOIN
     account a using (account_id)
         INNER JOIN
     disp as d using (account_id)
         INNER JOIN
     client as c using (client_id)
WHERE True
  AND l.status IN ('A', 'C')
  AND d.type = 'OWNER'
--  AND EXTRACT(YEAR FROM c.birth_date) > 1990
GROUP BY c.client_id
HAVING
    sum(amount - payments) > 1000
--    and count(loan_id) > 5
ORDER BY loans_amount DESC -- here we add descending sorting by number of loans

---------------------------------------------------------------------------------------------
-- Expiring cards ---------------------------------------------------------------------------
SELECT *
FROM
    INNER JOIN
        financial.disp as d using (account_id)
    INNER JOIN
        financial.client as c using (client_id)
    INNER JOIN
        financial.district as d2 on
            c.district_id = d2.district_id;

SELECT 
    c2.client_id,
    c.card_id,

    -- we calculate the expiration date according to the exercise conditions
    DATE_ADD(c.issued, INTERVAL 3 year) as expiration_date,
    d2.A3 as client_adress
FROM 
        financial.card as c
    INNER JOIN
        financial.disp as d using (disp_id)
    INNER JOIN
        financial.client as c2 using (client_id)
    INNER JOIN
        financial.district as d2 using (district_id);

WITH cte AS (
    SELECT 
        c2.client_id,
        c.card_id,
        -- we calculate the expiration date according to the exercise conditions
        DATE_ADD(c.issued, interval 3 year) as expiration_date,
        d2.A3 as client_adress
    FROM 
            financial.card as c
        INNER JOIN
            financial.disp as d using (disp_id)
        INNER JOIN
            financial.client as c2 using (client_id)
        INNER JOIN
            financial.district as d2 using (district_id)
)
SELECT * 
FROM cte;

WITH cte AS (
    SELECT 
        c2.client_id,
        c.card_id,

        -- we calculate the expiration date according to the exercise conditions
        DATE_ADD(c.issued, interval 3 year) as expiration_date,
        d2.A3 as client_adress
    FROM 
            financial.card as c
        INNER JOIN
            financial.disp as d using (disp_id)
        INNER JOIN
            financial.client as c2 using (client_id)
        INNER JOIN
            financial.district as d2 using (district_id)
)
SELECT * 
FROM cte
-- now from the full list of cards we select only those that are about to expire
WHERE '2000-01-01' BETWEEN DATE_ADD(expiration_date, INTERVAL -7 DAY) AND expiration_date;


CREATE TABLE financial.cards_at_expiration
(
    client_id       int                      not null,
    card_id         int default 0            not null,
    expiration_date date                     null,
    A3              varchar(15) charset utf8 not null,
    generated_for_date date                     null
);

WITH cte AS (
    SELECT 
        c2.client_id,
        c.card_id,

        -- we calculate the expiration date according to the exercise conditions
        DATE_ADD(c.issued, interval 3 year) as expiration_date,
        d2.A3 as client_adress
    FROM 
            financial.card as c
        INNER JOIN
            financial.disp as d using (disp_id)
        INNER JOIN
            financial.client as c2 using (client_id)
        INNER JOIN
            financial.district as d2 using (district_id)
)
SELECT * 
FROM cte
-- now from the full list of cards we select only those that are about to expire
WHERE p_date BETWEEN DATE_ADD(expiration_date, INTERVAL -7 DAY) AND expiration_date;

DELIMITER $$
DROP PROCEDURE IF EXISTS financial.generate_cards_at_expiration_report; 
CREATE PROCEDURE financial.generate_cards_at_expiration_report(p_date DATE)
BEGIN
END;
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS financial.generate_cards_at_expiration_report; 
CREATE PROCEDURE financial.generate_cards_at_expiration_report(p_date DATE)
BEGIN
    TRUNCATE TABLE financial.cards_at_expiration;
    INSERT INTO financial.cards_at_expiration
    WITH cte AS (
        SELECT c2.client_id,
               c.card_id,
               date_add(c.issued, interval 3 year) as expiration_date,
               d2.A3
        FROM 
            financial.card as c
                 INNER JOIN
             financial.disp as d using (disp_id)
                 INNER JOIN
             financial.client as c2 using (client_id)
                 INNER JOIN
             financial.district as d2 using (district_id)
    )
    SELECT
           *,
           p_date
    FROM cte
    WHERE p_date BETWEEN DATE_ADD(expiration_date, INTERVAL -7 DAY) AND expiration_date
    ;
END;
DELIMITER ;

CALL financial.generate_cards_at_expiration_report('2001-01-01');
SELECT * FROM financial.cards_at_expiration;
