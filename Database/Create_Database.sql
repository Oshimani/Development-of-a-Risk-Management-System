-- REMOVE ALL EXISTING DATABASES
SELECT 'Removing existing tables...';
DROP TABLE IF EXISTS t_stocks;
DROP TABLE IF EXISTS t_prices;

-- CREATE TABLES
SELECT 'Creating tables...';

-- CREATE TABLE STOCKS
CREATE TABLE t_stocks (
    isin            VARCHAR(16)     PRIMARY KEY NOT NULL,
    name            VARCHAR(255)    NOT NULL
);

-- CREATE STOCKS
-- CREATE DEUTSCHE BANK
INSERT INTO t_stocks (isin, name)
VALUES ('DE0005140008', 'Deutsche Bank');

-- CREATE MERCEDES BENZ
INSERT INTO t_stocks (isin, name)
VALUES ('DE0007100000', 'Mercedes-Benz Group');

-- CREATE TABLE PRICES
CREATE TABLE t_prices (
    isin            VARCHAR(16),
    value           NUMERIC,
    date            DATE,
    
    FOREIGN KEY (isin) REFERENCES t_stocks(isin)
);
