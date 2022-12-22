-- COUNT PRICE DATA SETS
SELECT
    COUNT(*)
FROM
    t_prices;

-- GET PRICE DATA SETS
SELECT
    *
FROM
    t_prices
WHERE
    isin = 'DE0005140008';

-- CLEAR PRICE DATA
TRUNCATE t_prices;

SELECT
    id,
    t_portfolios.name,
    stock_isin AS isin,
    amount,
    t_portfolios_stocks.date AS date,
    close,
    dailyreturns
FROM
    t_portfolios,
    t_portfolios_stocks,
    t_stocks,
    t_prices
WHERE
    t_portfolios.id = t_portfolios_stocks.portfolio_id
    AND t_portfolios_stocks.stock_isin = t_stocks.isin
    AND t_stocks.isin = t_prices.isin
    AND t_portfolios_stocks.date = t_prices.date;


-- SELECT
--     t_portfolios.name AS portfolioname,
--     amount,
--     t_stocks.isin AS isin,
--     t_stocks.name AS stockname,
--     t_prices.date AS date,
--     close,
--     dailyreturns
-- FROM
--     t_portfolios,
--     t_portfolios_stocks,
--     t_prices,
--     t_stocks
-- WHERE
--     t_portfolios.id = t_portfolios_stocks.portfolio_id
--     AND t_portfolios_stocks.stock_isin = t_stocks.isin
--     AND t_prices.isin = t_stocks.isin
-- LIMIT
--     100;