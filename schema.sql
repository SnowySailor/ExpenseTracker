DO $$
BEGIN
-- Terminate all connections
IF EXISTS (SELECT 1 FROM pg_database WHERE datname = 'COST_LOGGER') THEN
    REVOKE CONNECT ON DATABASE COST_LOGGER FROM public;
    PERFORM pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'COST_LOGGER';
END IF;
END$$ LANGUAGE plpgsql;

-- Drop and recreate database/schema
DROP DATABASE IF EXISTS COST_LOGGER;
CREATE DATABASE COST_LOGGER WITH OWNER = 'root' ENCODING = 'UTF8';
\connect cost_logger;


-- Create tables
CREATE TABLE APP_USER (
    Id            SERIAL PRIMARY KEY,
    Username      VARCHAR(100) NOT NULL,
    Display_Name  VARCHAR(100) NOT NULL,
    Email         VARCHAR(250) NOT NULL,
    Password_Hash VARCHAR(100) NOT NULL
);

CREATE TABLE TRANSACTION (
    Id             SERIAL PRIMARY KEY,
    Amount         DECIMAL   NOT NULL,
    Date           TIMESTAMP NOT NULL,
    UserId         INT       NOT NULL REFERENCES APP_USER(Id),
    LastUpdateTime TIMESTAMP NOT NULL
);

CREATE TABLE TRANSACTION_USER (
    TransactionId INT NOT NULL REFERENCES TRANSACTION(Id),
    UserId        INT NOT NULL REFERENCES APP_USER(Id),
    Percentage    DECIMAL NOT NULL,
    PRIMARY KEY (TransactionId, UserId)
);
