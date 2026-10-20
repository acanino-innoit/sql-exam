-- All rows should say PASS. No assessed answers are shown here.
SELECT 'users: 20000' AS check_name, CASE WHEN COUNT(*) = 20000 THEN 'PASS' ELSE 'FAIL' END AS result FROM sql_bi_exam.users
UNION ALL SELECT 'sessions: 220000', CASE WHEN COUNT(*) = 220000 THEN 'PASS' ELSE 'FAIL' END FROM sql_bi_exam.sessions
UNION ALL SELECT 'content: 1000', CASE WHEN COUNT(*) = 1000 THEN 'PASS' ELSE 'FAIL' END FROM sql_bi_exam.content
UNION ALL SELECT 'events: 800000', CASE WHEN COUNT(*) = 800000 THEN 'PASS' ELSE 'FAIL' END FROM sql_bi_exam.events
UNION ALL SELECT 'subscriptions: 15000', CASE WHEN COUNT(*) = 15000 THEN 'PASS' ELSE 'FAIL' END FROM sql_bi_exam.subscriptions
UNION ALL SELECT 'bonus rows: 15000', CASE WHEN COUNT(*) = 15000 THEN 'PASS' ELSE 'FAIL' END FROM sql_bi_exam.subscriptions_bonus;

SELECT 'session and event chronology' AS check_name,
       CASE WHEN NOT EXISTS (
           SELECT 1 FROM sql_bi_exam.events e
           JOIN sql_bi_exam.sessions s USING (session_id)
           JOIN sql_bi_exam.users u USING (user_id)
           WHERE e.event_time < s.session_start OR e.event_time >= s.session_end
              OR s.session_start::date < u.signup_date
       ) THEN 'PASS' ELSE 'FAIL' END AS result;
