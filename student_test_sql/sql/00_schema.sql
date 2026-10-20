-- Run this whole file in your course database. PostgreSQL 14+.
-- RESET: removes ONLY the sql_bi_exam schema and work previously saved in it.
BEGIN;
DROP SCHEMA IF EXISTS sql_bi_exam CASCADE;
CREATE SCHEMA sql_bi_exam;
SET LOCAL search_path TO sql_bi_exam, public;

CREATE TABLE users (
    user_id integer PRIMARY KEY,
    signup_date date NOT NULL,
    country text NOT NULL,
    acquisition_channel text NOT NULL
);
CREATE TABLE sessions (
    session_id integer PRIMARY KEY,
    user_id integer NOT NULL REFERENCES users(user_id),
    session_start timestamp NOT NULL,
    session_end timestamp NOT NULL,
    device_type text NOT NULL,
    CHECK (session_end > session_start)
);
CREATE TABLE content (
    content_id integer PRIMARY KEY,
    title text NOT NULL,
    category text NOT NULL,
    publish_date date NOT NULL
);
CREATE TABLE events (
    event_id integer PRIMARY KEY,
    session_id integer NOT NULL REFERENCES sessions(session_id),
    content_id integer NOT NULL REFERENCES content(content_id),
    event_time timestamp NOT NULL,
    event_type text NOT NULL,
    watch_seconds integer NOT NULL CHECK (watch_seconds >= 0)
);
CREATE TABLE subscriptions (
    subscription_id integer PRIMARY KEY,
    user_id integer NOT NULL REFERENCES users(user_id),
    plan text NOT NULL,
    start_date date NOT NULL,
    end_date date,
    monthly_price numeric(8,2) NOT NULL CHECK (monthly_price > 0),
    status text NOT NULL CHECK (status IN ('active', 'cancelled', 'paused')),
    CHECK (end_date IS NULL OR end_date > start_date)
);
-- Deliberately incomplete integrity rules, used ONLY for the optional bonus.
CREATE TABLE subscriptions_bonus (
    subscription_id integer PRIMARY KEY,
    user_id integer,
    plan text,
    monthly_price numeric(8,2),
    status text
);
COMMIT;
