-- COUNT PRICE DATA SETS
SELECT COUNT(*)
FROM t_prices;

-- GET PRICE DATA SETS
SELECT *
FROM t_prices
WHERE isin = 'DE0005140008';

-- CLEAR PRICE DATA
TRUNCATE t_prices;