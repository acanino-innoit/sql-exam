# SQL and Business Intelligence final assessment

Start with [EXAM.md](EXAM.md) for the challenges.

**Time:** 120 minutes, including up to 10 minutes for setup and troubleshooting. Individual work. Lessons 1–6 only.

## Before starting the questions

Use DBeaver and the same PostgreSQL database you used in the labs. Confirm Tableau Public desktop can open, edit, and save a local packaged workbook. Your instructor supplies the completed Tableau starter; report a missing workbook before the exam begins.

No Python, Docker, extra PostgreSQL driver for Tableau, or live PostgreSQL-to-Tableau connection is required.

## Database setup: supplied and ungraded

1. In DBeaver, connect to the same database used in the labs.
2. Open `sql/00_schema.sql` and run the **whole script**. This rebuilds the exam schema and removes previous work in that schema; do not run it again after starting your answers unless you want to reset them.
3. Open `sql/01_data.sql` and run the **whole script** once. Wait for it to finish.
4. Open `sql/02_setup_checks.sql` and run it. Every result should say `PASS`. If a check fails, tell the instructor; setup problems are not assessed.
5. Write and test your queries in any DBeaver SQL editor connected to the course database, as you did in the labs. To use the exam tables, run `SET search_path TO sql_bi_exam, public;` in that editor (again if you open a new editor or reconnect), or write table names with the `sql_bi_exam.` prefix. When finished, copy the queries required for your answers into `sql/student_answers.sql` for submission.

## Data dictionary

All timestamps are timezone-free business timestamps in one common reporting clock. Date intervals include their start and exclude their end. These are synthetic data, including the complete reporting year 2026.

| Table | Grain and keys | Other columns |
|---|---|---|
| `users` | One registered user; PK `user_id` | `signup_date`, `country`, `acquisition_channel` |
| `sessions` | One session; PK `session_id`; FK `user_id` → users | `session_start`, `session_end`, `device_type` |
| `content` | One content item; PK `content_id` | `title`, `category`, `publish_date` |
| `events` | One interaction with one content item in one session; PK `event_id`; FKs `session_id`, `content_id` | `event_time`, `event_type`, `watch_seconds` |
| `subscriptions` | One subscription period; PK `subscription_id`; FK `user_id` → users | `plan`, `start_date`, nullable `end_date`, `monthly_price`, `status` |
| `subscriptions_bonus` | Existing subscription rows with deliberately incomplete integrity rules; PK `subscription_id` | `user_id`, `plan`, `monthly_price`, `status` |

Relationships: users 1:N sessions; sessions 1:N events; content 1:N events; users 1:N subscription periods. A user may have no sessions. Prices are monthly monetary amounts in EUR. `watch_seconds` is watched duration, not an event count; non-watching interactions can have zero seconds.

For subscription snapshot analysis, use the period dates, not today's status. A period includes `start_date` and excludes `end_date`; null means no recorded end. Status is descriptive and is not a historical snapshot.

## Tableau is independent

Open `tableau/flawed-dashboard.twbx` directly. If it will not open for any reason, import `tableau/exam_data.csv` into Tableau, create a new workbook and dashboard for Q6 and Q7, and save it as `submission/corrected_workbook.twbx`. The CSV is a separate prepared sample, not the full PostgreSQL dataset. Do not connect to PostgreSQL or export your SQL results.

Tableau source columns: `event_id` (unique interaction), `user_id`, `event_time`, `country`, `category`, `watch_seconds` (non-null integer seconds). Every row is an event in 2026. A user may occur many times. Before saving, select **Extract** for the CSV data source and complete the extraction prompt; save a packaged workbook (`.twbx`), then close and reopen it to check that both views and their values appear. Notify the instructor about broken connections.

## Submit

Save your SQL in `sql/student_answers.sql`, your explanations in `submission/answers.md`, and your corrected workbook as `submission/corrected_workbook.twbx`. You may also save a screenshot showing the finished Q6 and Q7 dashboard views and visible values as `submission/dashboard_screenshot.png`. It is only backup evidence if the workbook cannot be opened during grading; it is not needed when the workbook opens correctly. If the workbook cannot be opened and no screenshot is available, dashboard view points cannot be awarded; written answers are graded separately.

Create your own GitHub repository containing the exam files and your answers. Commit and push your final work to the repository's `main` or `master` branch, then email the repository link to the professor. The professor will download and grade the latest commit on that branch, so make sure all required files are present there before sending the link. A single commit is acceptable; commit history and style are not assessed. Make sure the professor can access the repository.

Before submitting, reopen your SQL and workbook, check the three required deliverables, and verify your name/student ID. Do not include passwords, local database files, or unrelated exports.
