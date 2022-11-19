-- REMOVE ALL EXISTING TABLES
DROP TABLE IF EXISTS t_stocks;

DROP TABLE IF EXISTS t_prices;

DROP TABLE IF EXISTS t_portfolios;

DROP TABLE IF EXISTS t_portfolios_stocks;

-- REMOVE ALL EXISTING VIEWS
DROP VIEW IF EXISTS v_trades;

-- CREATE TABLES
-- CREATE TABLE STOCKS
CREATE TABLE t_stocks (
    isin VARCHAR(16) PRIMARY KEY NOT NULL,
    name VARCHAR(255) NOT NULL
);

-- CREATE STOCKS
-- CREATE DEUTSCHE BANK
INSERT INTO
    t_stocks (isin, name)
VALUES
    ('DE0005140008', 'Deutsche Bank');

-- CREATE MERCEDES BENZ
INSERT INTO
    t_stocks (isin, name)
VALUES
    ('DE0007100000', 'Mercedes-Benz Group');

-- CREATE TABLE PRICES
CREATE TABLE t_prices (
    isin VARCHAR(16),
    close NUMERIC,
    dailyreturns NUMERIC,
    date DATE,
    FOREIGN KEY (isin) REFERENCES t_stocks(isin)
);

-- CREATE TABLE PORTFOLIOS
CREATE TABLE t_portfolios (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL
);

-- CREATE TABLE PORTFOLIOS_STOCKS (consists of in ER)
CREATE TABLE t_portfolios_stocks (
    portfolio_id INTEGER NOT NULL,
    stock_isin VARCHAR(16) NOT NULL,
    amount NUMERIC NOT NULL,
    date DATE NOT NULL,
    FOREIGN KEY (portfolio_id) REFERENCES t_portfolios(id) ON DELETE CASCADE,
    FOREIGN KEY (stock_isin) REFERENCES t_stocks(isin)
);

-- CREATE VIEW TO FETCH PORTFOLIO WITH ITS STOCKS
CREATE VIEW v_trades AS (
    SELECT
        id,
        name,
        stock_isin AS isin,
        amount,
        date
    FROM
        t_portfolios AS t_p,
        t_portfolios_stocks AS t_ps
    WHERE
        t_p.id = t_ps.portfolio_id
);