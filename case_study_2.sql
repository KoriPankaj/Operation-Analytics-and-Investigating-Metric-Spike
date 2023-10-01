CREATE DATABASE opt_ana_2;
USE opt_ana_2;

CREATE TABLE users(  
user_id int, 
created_at varchar(100), 
company_id int, 
language varchar(50), 
activated_at varchar(100), 
state varchar(50)) ; 
 
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users.csv" 
INTO TABLE users 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;  

SELECT * FROM users;

ALTER TABLE users ADD COLUMN temp_created_at DATETIME;
SET SQL_SAFE_UPDATES = 0;

UPDATE users SET temp_created_at = str_to_date(created_at, '%d-%m-%Y %H:%i');
ALTER TABLE users DROP COLUMN created_at;
ALTER TABLE users CHANGE COLUMN temp_created_at created_at DATETIME;

# Table 2 events
CREATE TABLE events (
user_id INT,
occurred_at VARCHAR(100),
event_type VARCHAR(50),
event_name VARCHAR(100),
location VARCHAR(50),
device VARCHAR(50),
user_type INT);

SELECT * FROM events;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/events.csv'
INTO TABLE events
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;  

ALTER TABLE events ADD COLUMN temp_occured_at DATETIME;
SET SQL_SAFE_UPDATES = 0;
UPDATE events SET temp_occured_at = str_to_date(occurred_at, '%d-%m-%Y %H:%i');
ALTER TABLE events DROP COLUMN occurred_at;
ALTER TABLE events CHANGE COLUMN temp_occured_at occurred_at DATETIME;

# TABLE email_events
CREATE TABLE email_events(
user_id int,
occurred_at varchar(100),
action varchar(100),
user_type int 
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/email_events.csv"
INTO TABLE email_events
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;  

SELECT * FROM email_events;

ALTER TABLE email_events ADD COLUMN temp_occured_at DATETIME;
SET SQL_SAFE_UPDATES = 0;
UPDATE email_events SET temp_occured_at = str_to_date(occurred_at, '%d-%m-%Y %H:%i');
ALTER TABLE email_events DROP COLUMN occurred_at;
ALTER TABLE email_events CHANGE COLUMN temp_occured_at occurred_at DATETIME;

# Weekly user engagement
SELECT *  FROM users;

SELECT week(STR_TO_DATE(activated_at,'%d-%m-%Y %H:%i')) AS weeks, COUNT(*) AS users
FROM users
GROUP BY weeks
ORDER BY  weeks;

SELECT MAX(users) AS max_users_active
FROM (
SELECT week(STR_TO_DATE(activated_at,'%d-%m-%Y %H:%i')) AS weeks, COUNT(*) AS users
FROM users
GROUP BY weeks
ORDER BY  weeks
) AS subquery;

# User Growth Analysis
SELECT avg(new_users) AS users_registered
FROM (
SELECT date(STR_TO_DATE(created_at, '%Y-%m-%d %H:%i')) AS registration_on_week, COUNT(*) AS new_users
FROM users
GROUP BY registration_on_week
ORDER BY  registration_on_week
) AS subquery;

# Weekly Retention Analysis
SELECT user_id, WEEK(occurred_at) AS week_number, COUNT(*) AS engagement_count
FROM events
WHERE event_type = 'engagement'
GROUP BY  user_id, week_number
ORDER BY user_id, week_number;

SELECT max(weeks_engaged) as max_week_engaged
From( SELECT  user_id, COUNT(DISTINCT WEEK(STR_TO_DATE(occurred_at, '%Y-%m-%d %H:%i'))) AS weeks_engaged
FROM events
WHERE event_type = 'engagement'
GROUP BY user_id) as subquery;


# Weekly Engagement Per Device:
SELECT * FROM events;
SELECT WEEK(STR_TO_DATE(occurred_at, '%Y-%m-%d %H:%i')) AS week_number, device, COUNT(*) AS users_engagement
FROM events
WHERE event_type = 'engagement'
GROUP BY device, week_number
ORDER BY week_number;

SELECT device, max(users_engagement) as max_user_engaged FROM
(
SELECT WEEK(STR_TO_DATE(occurred_at, '%Y-%m-%d %H:%i')) AS week_number, device, COUNT(*) AS users_engagement
FROM events
WHERE event_type = 'engagement'
GROUP BY device, week_number
ORDER BY week_number)  as subquery group by device order by max_user_engaged;

SELECT
    WEEK(STR_TO_DATE(occurred_at, '%Y-%m-%d %H:%i')) AS week_number,
    device,
    COUNT(*) AS engagement_count
FROM
    events
GROUP BY
    week_number, device
ORDER BY
    week_number, device;

# Email Engagement Analysis
SELECT * FROM email_events;

SELECT user_id, action, COUNT(DISTINCT DAY(occurred_at)) AS days_engaged
FROM email_events
GROUP BY user_id, action;

SELECT user_id, action, COUNT(DISTINCT DAY(occurred_at)) AS days_engaged
FROM email_events
Where action = 'email_open'
GROUP BY user_id, action;

SELECT AVG(days_engaged) AS average_days_engaged
FROM (
    SELECT user_id, COUNT(DISTINCT DAY(occurred_at)) AS days_engaged
    FROM email_events
    WHERE action = 'email_open'
    GROUP BY user_id
) AS subquery;

SELECT AVG(days_engaged) AS average_days_engaged
FROM (
    SELECT user_id, COUNT(DISTINCT DAY(occurred_at)) AS days_engaged
    FROM email_events
    WHERE action = 'sent_weekly_digest'
    GROUP BY user_id
) AS subquery;

SELECT AVG(days_engaged) AS average_days_engaged
FROM (
    SELECT user_id, COUNT(DISTINCT DAY(occurred_at)) AS days_engaged
    FROM email_events
    WHERE action = 'email_clickthrough'
    GROUP BY user_id
) AS subquery;