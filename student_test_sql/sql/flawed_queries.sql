-- Read these queries; put your corrected versions in student_answers.sql.
-- They execute successfully but do not satisfy the business requirements.
SET search_path TO sql_bi_exam, public;

-- Q3: monthly subscription value at 2026-09-01, by country.
SELECT u.country, SUM(su.monthly_price) AS monthly_subscription_value
FROM users u
JOIN subscriptions su ON su.user_id = u.user_id
JOIN sessions s ON s.user_id = u.user_id
WHERE su.start_date <= DATE '2026-09-01'
  AND (su.end_date IS NULL OR su.end_date > DATE '2026-09-01')
GROUP BY u.country
ORDER BY u.country;

-- Q4: registered users and September-active users, by signup month.
WITH activity AS (
    SELECT u.user_id, u.signup_date, s.session_id
    FROM users u
    LEFT JOIN sessions s ON s.user_id = u.user_id
    WHERE s.session_start >= TIMESTAMP '2026-09-01'
      AND s.session_start < TIMESTAMP '2026-10-01'
)
SELECT DATE_TRUNC('month', signup_date)::date AS signup_month,
       COUNT(DISTINCT user_id) AS registered_users,
       COUNT(DISTINCT user_id) AS september_active_users
FROM activity
GROUP BY DATE_TRUNC('month', signup_date)::date
ORDER BY signup_month;

-- Q5A: count all recorded sessions for EVERY registered user, including zero.
SELECT u.user_id, COUNT(*) AS session_count
FROM users u LEFT JOIN sessions s ON s.user_id = u.user_id
GROUP BY u.user_id
ORDER BY u.user_id;

-- Q5B: previous session in chronological order for the same user.
SELECT session_id, user_id, session_start,
       LAG(session_start) OVER (PARTITION BY user_id) AS previous_session
FROM sessions;
