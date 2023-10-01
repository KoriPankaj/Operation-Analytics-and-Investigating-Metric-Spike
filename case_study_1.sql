CREATE DATABASE Opt_ana;
USE Opt_ana;

# ds	job_id	actor_id	event	language	time_spent	org

CREATE TABLE job_data(
ds VARCHAR(255),
job_id INT,
actor_id INT,
`event` VARCHAR(255),
`language` VARCHAR(255),
time_spent INT,
org CHAR) ;

SELECT * FROM job_data;
SELECT * FROM job_data_direct;



DESCRIBE job_data_direct;

SELECT
    STR_TO_DATE(ds, '%m/%d/%Y') AS review_date,
    COUNT(job_id) AS jobs_reviewed,
    SUM(time_spent / 3600) AS review_per_hours
FROM job_data_direct
WHERE STR_TO_DATE(ds, '%m/%d/%Y') BETWEEN '2020-11-01' AND '2020-11-30'
GROUP BY review_date;

SELECT STR_TO_DATE(ds, '%m/%d/%Y') AS review_date, COUNT(`event`) AS no_of_events, SUM(time_spent) as timespent_in_events,
COUNT(`event`) / SUM(time_spent) AS events_per_sec 
FROM job_data_direct 
GROUP BY review_date;

# Rolling avg of throghput 
SELECT review_date,no_of_events,timespent_in_events,events_per_sec,
    AVG(events_per_sec) 
    OVER (
        ORDER BY review_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS sevenday_rolling_avg FROM
    (SELECT STR_TO_DATE(ds, '%m/%d/%Y') AS review_date, COUNT(`event`) AS no_of_events, SUM(time_spent) as timespent_in_events,
COUNT(`event`) / SUM(time_spent) AS events_per_sec 
FROM job_data_direct 
GROUP BY review_date) AS subquery;

# Task 2 Throughput ANalysis
SELECT STR_TO_DATE(ds, '%m/%d/%Y') AS review_date, COUNT(`event`) AS no_of_events, SUM(time_spent) as timespent_in_events,
COUNT(`event`) / SUM(time_spent) AS no_of_events_per_sec
FROM job_data_direct 
GROUP BY review_date;

select * from job_data_direct;
# Languauge share analysis

SELECT
    `language`,
    COUNT(*) AS language_count,
    (COUNT(*) / total_count) * 100 AS percentage_share
FROM
    job_data_direct
CROSS JOIN (
    SELECT COUNT(*) AS total_count
    FROM job_data_direct
    WHERE STR_TO_DATE(ds, '%m/%d/%Y') >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
) AS total_counts
WHERE
    STR_TO_DATE(ds, '%m/%d/%Y') >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY
    `language`
ORDER BY
    percentage_share DESC;


SELECT
    `language`,
    COUNT(*) AS language_count,
    (COUNT(*) / total_count) * 100 AS percentage_share
FROM
    job_data_direct,
    (SELECT COUNT(*) AS total_count FROM job_data_direct) AS subquery
WHERE
    STR_TO_DATE(ds, '%m/%d/%Y') BETWEEN '2020-11-01' AND '2020-11-30'
GROUP BY
    `language`
ORDER BY
    percentage_share DESC;


SELECT`language`,COUNT(*) AS language_count,(COUNT(*) / MAX(total_count)) * 100 AS percentage_share
FROM job_data_direct,
    (SELECT COUNT(*) AS total_count FROM (SELECT STR_TO_DATE(ds, '%m/%d/%Y') AS review_date FROM job_data_direct
WHERE STR_TO_DATE(ds, '%m/%d/%Y') 
GROUP BY review_date)AS subquery) AS subquery_total
WHERE STR_TO_DATE(ds, '%m/%d/%Y') BETWEEN '2020-11-01' AND '2020-11-30'
GROUP BY `language`
ORDER BY percentage_share DESC;
    
SELECT COUNT(*) AS total_count FROM (SELECT STR_TO_DATE(ds, '%m/%d/%Y') AS review_date FROM job_data_direct
WHERE STR_TO_DATE(ds, '%m/%d/%Y') 
GROUP BY review_date)AS subquery;

SELECT STR_TO_DATE(ds, '%m/%d/%Y') AS review_date, `language` from job_data_direct;


SELECT
    `language`,
    COUNT(*) AS language_count,
    (COUNT(*) / total_count) * 100 AS percentage_share
FROM
    job_data_direct,
    (SELECT COUNT(DISTINCT STR_TO_DATE(ds, '%m/%d/%Y')) AS total_count FROM job_data_direct) AS subquery
GROUP BY
    `language`
ORDER BY
    percentage_share DESC;

# Duplicate Rows detection

SELECT * FROM job_data_direct
GROUP BY ds, job_id, actor_id, `event`, `language`, time_spent, org
HAVING COUNT(*) > 1;

