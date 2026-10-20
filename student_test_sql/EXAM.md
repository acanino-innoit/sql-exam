# Audience Analytics: SQL and BI assessment

**120 minutes · individual work**

You are reviewing reporting for a digital-media service. Deliver correct business queries, diagnose misleading SQL, and repair two Tableau views.

Suggested timing: setup and troubleshooting up to 10 minutes; Q1–Q2 20 minutes; Q3–Q5 50 minutes; Q6–Q7 30 minutes; checking/submission 10 minutes. If setup finishes quickly, use the extra time for your answers. The bonus is optional and must not prevent completion of the core tasks.

## Rules

- You may consult course notes, old labs, documentation, and ordinary web search. Your submitted SQL and explanations must be your own.
- Generative AI assistance is prohibited, including chatbots, coding assistants, and AI-generated search answers or summaries. Ordinary search may locate documentation.
- Setup is supplied and ungraded. Do not change the source data to make an answer work. Put answers in the designated files.
- Equivalent correct approaches receive equal credit unless the question explicitly assesses a named feature. CTEs, subqueries, and direct queries are acceptable.
- Explain specific analytical consequences, not personal visual taste. Concise explanations are sufficient.
- Lessons 7 topics are not assessed. No `CASE`, `FULL OUTER JOIN`, set operations, views, `LATERAL`, or stored-programming solution is required.

## A. Business queries

### Q1. September audience

How many distinct registered users had at least one session **starting on or after 1 September 2026 and before 1 October 2026**? Activity is defined by session start, not event time.

Return one row with column `active_users`. Write the query in `sql/student_answers.sql`.

### Q2. Category engagement

For interactions with `event_time` **on or after 1 January 2026 and before 1 January 2027**, return content categories with **strictly more than 100,000 total watched seconds**, highest total first. Include all event types; sum their recorded `watch_seconds`.

Return `category`, `total_watch_seconds`. Write the query in the SQL answers file.

## B. SQL repair and reasoning

The starting queries in `sql/flawed_queries.sql` execute but do not meet the requirements below. Put corrected queries in the SQL answers file and explanations in `submission/answers.md`.

### Q3. Subscription snapshot

Report **monthly subscription value as of 1 September 2026 by country**. A subscription period qualifies when its start is on or before that date and its end is null or later than that date. Sum each qualifying period's `monthly_price` once.

Include qualifying subscriptions even if the user has no sessions. Return only countries with qualifying subscriptions, ordered alphabetically, with columns `country`, `monthly_subscription_value`.

This is monthly contractual value in EUR, **not cash revenue collected**. Use period dates; do not filter on `status`.

Identify the duplicated metric, explain why the rows multiply, describe your repair strategy, and provide corrected SQL.

### Q4. Preserve the signup population

For **every signup month represented in `users`**, report:

- `registered_users`: all users registered in that month, including users with no sessions;
- `september_active_users`: those registered users with at least one session starting during September 2026.

Return `signup_month` (first day of the month as a date), `registered_users`, `september_active_users`, ordered by month. Count users, not sessions. Zero activity must appear as zero, not as a missing cohort.

Explain why the existing filter loses users despite the `LEFT JOIN`, and correct the query. You may replace the CTE or use another equivalent construction.

### Q5A. Counting after an outer join

The supplied query should return **every registered user and their number of recorded sessions across all dates**, including zero. Explain what `COUNT(*)` counts for a user with no sessions. Repair it and return `user_id`, `session_count`, ordered by user ID.

### Q5B. What does “previous” mean?

Explain why the supplied `LAG()` expression does not reliably identify the previous session for a user. Repair the window specification. Order each user's sessions by `session_start`, breaking ties by `session_id` ascending. Return all sessions and columns `session_id`, `user_id`, `session_start`, `previous_session`. The first session for each user has a null previous value. Final display order is not assessed here.

### Q5C. Growing session history

The service frequently runs:

```sql
SELECT * FROM sql_bi_exam.sessions WHERE user_id = 18432;
```

The table contains hundreds of thousands of rows and continues to grow. Usually only a small fraction belongs to the requested user. The provided table has its primary-key access structure but no additional access structure for this lookup.

What database design change would you consider? Give concrete SQL if applicable. Explain why it fits this access pattern and name one cost or limitation. You are not required to measure runtime or obtain a particular execution plan.

## C. Tableau correction

Open the supplied `tableau/flawed-dashboard.twbx`. Work on its existing worksheets and dashboard. If the supplied workbook will not open for any reason, import `tableau/exam_data.csv` and create a new workbook with Q6 and Q7 views. Save the result as `submission/corrected_workbook.twbx`. Select **Extract** for the data source, complete the extraction prompt, and save the packaged workbook. Close and reopen it to verify that both views and their values appear. You may also save a screenshot of the finished dashboard with both views and visible values as `submission/dashboard_screenshot.png` for backup if the workbook cannot be opened during grading. **If the submitted dashboard is not saved in a way the instructor can open and there is no screenshot, the dashboard portion will receive 0 points.**

### Q6. Communicate monthly audience

Business question: **How did monthly active users change from January through December 2026?** Here an active user has at least one event in that month in the Tableau sample.

Inspect worksheet `Q6 Monthly Audience`. Identify **exactly three distinct problems**, explain their analytical or communication consequences, and propose a correction for each. Use the lesson 6 criteria: business fit, correct encoding, truthfulness, clarity, and signal versus noise. Repeated descriptions of the same issue earn credit once. The first three issues in your answer are graded.

Correct the existing view: use a suitable chronological representation, preserve distinct monthly user counts, make metric and reporting period clear, and remove distracting encoding. Record the three issue/consequence/correction entries in your written answers.

### Q7. Match metric and grain

Business question: **During 2026, what was the average total watched time per active user in this Tableau sample?** Active means having at least one event in 2026. Users without events are outside this metric's denominator. Use all 2026 events and do not split the metric by month, country, or category.

Inspect worksheet `Q7 Engagement`, labeled `Average Engagement per Active User — 2026` and currently based on `AVG(watch_seconds)`.

State the source grain, explain the mismatch, and correct the calculation and view to show **seconds per active user over the whole year**. Use calculations and aggregations studied in lesson 6; advanced Tableau LOD calculations are not required. Retain a single overall KPI and write one sentence interpreting the corrected value.

## D Optional bonus. Repair integrity rules

The existing populated `subscriptions_bonus` table is missing business rules. Use `ALTER TABLE` to enforce:

- Every subscription must belong to an existing user; null user IDs are not allowed.
- `plan` is required.
- `monthly_price` is required and strictly greater than zero.
- `status` is required and must be `active`, `cancelled`, or `paused`.
- A user may have multiple subscription rows. Explain why uniqueness on `user_id` would be inappropriate.

Do not drop, recreate, or empty the table. Existing rows satisfy these rules. Run your bonus statements separately from the SELECT answers; rerunning already-added constraints can fail because they already exist.

## Final checklist

- SQL answers saved, with question labels.
- Written explanations completed in `submission/answers.md`.
- Corrected packaged Tableau workbook saved and reopened successfully; optional backup screenshot saved if desired.
- Name/student ID recorded; final files pushed to your own GitHub repository's `main` or `master` branch, and the repository link emailed to the professor. The latest commit on that branch is graded.
