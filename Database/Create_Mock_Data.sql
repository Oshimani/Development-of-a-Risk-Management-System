-- CREATE PORTFOLIO FOR Jannick
INSERT INTO
    t_portfolios (name)
VALUES
    ('Portfolio von Jannick');

-- BUY 100 Deutsche Bank @2021-01-01 FOR Jannick
INSERT INTO
    t_portfolios_stocks(portfolio_id, stock_isin, amount, date)
VALUES
    (
        (
            SELECT
                id
            FROM
                t_portfolios
            WHERE
                name = 'Portfolio von Jannick'
        ),
        (
            SELECT
                isin
            FROM
                t_stocks
            WHERE
                name = 'Deutsche Bank'
        ),
        1000,
        '2021-01-10'
    );

-- BUY 50 Mercedes Benz Group @2021-01-01 FOR Jannick
INSERT INTO
    t_portfolios_stocks(portfolio_id, stock_isin, amount, date)
VALUES
    (
        (
            SELECT
                id
            FROM
                t_portfolios
            WHERE
                name = 'Portfolio von Jannick'
        ),
        (
            SELECT
                isin
            FROM
                t_stocks
            WHERE
                name = 'Mercedes-Benz Group'
        ),
        100,
        '2021-01-05'
    );

-- GET JANNICK'S PORTFOLIO 
SELECT
    *
FROM
    v_portfolios
WHERE
    name = 'Portfolio von Jannick';

-- CREATE PORTFOLIO FOR Liwen
INSERT INTO
    t_portfolios (name)
VALUES
    ('Portfolio von Liwen');

-- BUY 100 Deutsche Bank @2021-01-01 FOR Liwen
INSERT INTO
    t_portfolios_stocks(portfolio_id, stock_isin, amount, date)
VALUES
    (
        (
            SELECT
                id
            FROM
                t_portfolios
            WHERE
                name = 'Portfolio von Liwen'
        ),
        (
            SELECT
                isin
            FROM
                t_stocks
            WHERE
                name = 'Deutsche Bank'
        ),
        100,
        '2021-01-01'
    );

-- BUY 100 Mercedes Benz Group @2021-01-01 FOR Liwen
INSERT INTO
    t_portfolios_stocks(portfolio_id, stock_isin, amount, date)
VALUES
    (
        (
            SELECT
                id
            FROM
                t_portfolios
            WHERE
                name = 'Portfolio von Liwen'
        ),
        (
            SELECT
                isin
            FROM
                t_stocks
            WHERE
                name = 'Mercedes-Benz Group'
        ),
        100,
        '2021-01-01'
    );

-- GET LIWEN'S PORTFOLIO 
SELECT
    *
FROM
    v_portfolios
WHERE
    name = 'Portfolio von Liwen';

-- CREATE PORTFOLIO FOR Philipp
INSERT INTO
    t_portfolios (name)
VALUES
    ('Portfolio von Philipp');

-- BUY 1000 Deutsche Bank @2021-01-10 FOR Philipp
INSERT INTO
    t_portfolios_stocks(portfolio_id, stock_isin, amount, date)
VALUES
    (
        (
            SELECT
                id
            FROM
                t_portfolios
            WHERE
                name = 'Portfolio von Philipp'
        ),
        (
            SELECT
                isin
            FROM
                t_stocks
            WHERE
                name = 'Deutsche Bank'
        ),
        1000,
        '2021-01-10'
    );

-- SELL 100 Deutsche Bank @2021-01-20 FOR Philipp
INSERT INTO
    t_portfolios_stocks(portfolio_id, stock_isin, amount, date)
VALUES
    (
        (
            SELECT
                id
            FROM
                t_portfolios
            WHERE
                name = 'Portfolio von Philipp'
        ),
        (
            SELECT
                isin
            FROM
                t_stocks
            WHERE
                name = 'Deutsche Bank'
        ),
        -500,
        '2021-01-15'
    );