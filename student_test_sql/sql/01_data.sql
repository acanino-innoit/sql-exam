-- Supplied, deterministic setup. Do not edit for the assessment.
-- Always run 00_schema.sql first. Run this entire file once, then 02_setup_checks.sql.
BEGIN;
SET LOCAL search_path TO sql_bi_exam, public;
INSERT INTO users
SELECT g, DATE '2025-01-01' + ((g * 17) % 365),
       (ARRAY['Spain','France','Germany','Italy','Portugal'])[1 + g % 5],
       (ARRAY['organic','paid_search','social','referral'])[1 + g % 4]
FROM generate_series(1, 20000) AS t(g);

INSERT INTO content
SELECT g, 'Content ' || g,
       CASE WHEN g = 1000 THEN 'Archive'
            ELSE (ARRAY['News','Sport','Culture','Science','Technology','Travel'])[1 + g % 6] END,
       DATE '2024-01-01' + (g % 365)
FROM generate_series(1, 1000) AS t(g);

WITH generated AS (
    SELECT g,
           CASE WHEN g <= 3 OR g % 11 = 0 THEN 1 ELSE 1 + (g * 37) % 18000 END AS uid,
           CASE WHEN g IN (1,2) THEN TIMESTAMP '2026-01-01 10:00:00'
                WHEN g = 3 THEN TIMESTAMP '2026-01-01 11:00:00'
                WHEN g = 219999 THEN TIMESTAMP '2025-12-31 23:59:00'
                WHEN g = 220000 THEN TIMESTAMP '2027-01-01 00:00:00'
                ELSE TIMESTAMP '2026-01-01' + ((g * 97) % 365) * INTERVAL '1 day'
                     + ((g * 1777) % 85500) * INTERVAL '1 second'
           END AS started
    FROM generate_series(1, 220000) AS t(g)
)
INSERT INTO sessions
SELECT g, uid, started, started + INTERVAL '15 minutes',
       (ARRAY['mobile','desktop','tablet'])[1 + g % 3]
FROM generated;

WITH generated AS (
    SELECT g,
           CASE WHEN g = 799999 THEN 219999 WHEN g = 800000 THEN 220000
                ELSE 1 + ((g::bigint * 41) % 219998)::integer END AS sid,
           CASE WHEN g % 100000 = 0 THEN 1000 ELSE 1 + (g * 43) % 999 END AS cid
    FROM generate_series(1, 800000) AS t(g)
)
INSERT INTO events
SELECT g, sid, cid, s.session_start + (1 + g % 30) * INTERVAL '1 second',
       CASE WHEN g % 100 < 92 THEN 'view' WHEN g % 100 < 98 THEN 'share' ELSE 'save' END,
       CASE WHEN g % 100 < 92 THEN 10 + (g * 13) % 591 ELSE 0 END
FROM generated JOIN sessions s ON s.session_id = sid;

-- Three non-overlapping periods each for 5,000 users; two snapshot boundaries.
WITH generated AS (
    SELECT g, CASE WHEN (g - 1) % 5000 = 4999 THEN 18001
                   ELSE 1 + (g - 1) % 5000 END AS uid,
           (g - 1) / 5000 AS period
    FROM generate_series(1, 15000) AS t(g)
)
INSERT INTO subscriptions
SELECT g, uid,
       (ARRAY['Basic','Standard','Premium'])[1 + uid % 3],
       CASE period WHEN 0 THEN DATE '2026-01-01' WHEN 1 THEN DATE '2026-05-01'
            ELSE CASE WHEN uid = 2 THEN DATE '2026-09-02' ELSE DATE '2026-09-01' END END,
       CASE period WHEN 0 THEN DATE '2026-05-01'
            WHEN 1 THEN CASE WHEN uid = 1 THEN DATE '2026-09-02' ELSE DATE '2026-09-01' END
            ELSE NULL END,
       (ARRAY[5.00,10.00,15.00])[1 + uid % 3],
       CASE WHEN period = 2 THEN 'active' ELSE 'cancelled' END
FROM generated;
-- The special uid=1 period above ends 2026-09-02, so delay its next start too.
UPDATE subscriptions SET start_date = DATE '2026-09-02' WHERE subscription_id = 10001;

INSERT INTO subscriptions_bonus
SELECT subscription_id, user_id, plan, monthly_price, status FROM subscriptions;
ANALYZE users;
ANALYZE sessions;
ANALYZE content;
ANALYZE events;
ANALYZE subscriptions;
COMMIT;
