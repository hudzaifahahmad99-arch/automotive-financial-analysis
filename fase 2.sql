CREATE TABLE dim_company (
    company_id   SERIAL PRIMARY KEY,
    ticker       VARCHAR(10) NOT NULL UNIQUE,   -- ASII, AUTO, GJTL, SMSM, IMAS, BOLT, INDS
    company_name VARCHAR(100) NOT NULL
);
 
CREATE TABLE dim_period (
    period_id  SERIAL PRIMARY KEY,
    fiscal_year INT NOT NULL UNIQUE             -- 2022, 2023, 2024, 2025
);

CREATE TABLE fact_financials (
    fact_id             SERIAL PRIMARY KEY,
    company_id          INT NOT NULL REFERENCES dim_company(company_id),
    period_id           INT NOT NULL REFERENCES dim_period(period_id),
 
    -- Laba Rugi
    revenue             NUMERIC(20,2),
    cogs                NUMERIC(20,2),
    gross_profit        NUMERIC(20,2),
    operating_profit    NUMERIC(20,2),
    net_profit          NUMERIC(20,2),
 
    -- Neraca
    current_assets      NUMERIC(20,2),
    current_liabilities NUMERIC(20,2),
    inventory            NUMERIC(20,2),
    receivables          NUMERIC(20,2),          -- piutang usaha
    payables              NUMERIC(20,2),          -- utang usaha
    total_assets          NUMERIC(20,2),
    total_equity          NUMERIC(20,2),
 
    UNIQUE (company_id, period_id)               -- satu emiten cuma 1 baris per tahun
);

INSERT INTO dim_company (ticker, company_name) VALUES
('ASII', 'Astra International'),
('AUTO', 'Astra Otoparts'),
('GJTL', 'Gajah Tunggal'),
('SMSM', 'Selamat Sempurna'),
('IMAS', 'Indomobil Sukses Internasional'),
('BOLT', 'Garuda Metalindo'),
('INDS', 'Indospring');
 
INSERT INTO dim_period (fiscal_year) VALUES
(2022), (2023), (2024), (2025);

CREATE TABLE tmp_staging (
    ticker               VARCHAR(10),
    fiscal_year          INT,
    revenue              NUMERIC(20,2),
    cogs                 NUMERIC(20,2),
    gross_profit         NUMERIC(20,2),
    operating_profit     NUMERIC(20,2),
    net_profit           NUMERIC(20,2),
    current_assets       NUMERIC(20,2),
    current_liabilities  NUMERIC(20,2),
    inventory            NUMERIC(20,2),
    receivables          NUMERIC(20,2),
    payables             NUMERIC(20,2),
    total_assets         NUMERIC(20,2),
    total_equity         NUMERIC(20,2)
);

copy tmp_staging FROM 'E:\Jay\DA\Hudza\Peoject 6\fact_financials_staging.csv' WITH (FORMAT csv, HEADER true);

INSERT INTO fact_financials (
    company_id, period_id, revenue, cogs, gross_profit, operating_profit,
    net_profit, current_assets, current_liabilities, inventory,
    receivables, payables, total_assets, total_equity
)
SELECT
    c.company_id, p.period_id, s.revenue, s.cogs, s.gross_profit, s.operating_profit,
    s.net_profit, s.current_assets, s.current_liabilities, s.inventory,
    s.receivables, s.payables, s.total_assets, s.total_equity
FROM tmp_staging s
JOIN dim_company c ON c.ticker = s.ticker
JOIN dim_period  p ON p.fiscal_year = s.fiscal_year;

SELECT COUNT(*) AS total_baris FROM fact_financials;

SELECT c.ticker, p.fiscal_year, f.revenue, f.net_profit
FROM fact_financials f
JOIN dim_company c ON c.company_id = f.company_id
JOIN dim_period  p ON p.period_id = f.period_id
WHERE c.ticker = 'ASII' AND p.fiscal_year = 2022;