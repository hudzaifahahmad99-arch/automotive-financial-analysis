-- ============================================================
-- PROJECT 6 — FASE 3: Query & Kalkulasi Rasio
-- ============================================================

-- ============================================================
-- ITEM 12-14: View gabungan margin, current ratio, CCC
-- (View, bukan tabel — supaya otomatis update kalau fact_financials berubah,
--  dan nanti tinggal konek langsung dari Power BI di Fase 4)
-- ============================================================

CREATE VIEW v_ratios AS
SELECT
    c.ticker,
    c.company_name,
    p.fiscal_year,

    -- Item 12: Margin (%)
    ROUND(f.gross_profit / NULLIF(f.revenue, 0) * 100, 2)      AS gross_margin_pct,
    ROUND(f.operating_profit / NULLIF(f.revenue, 0) * 100, 2)  AS operating_margin_pct,
    ROUND(f.net_profit / NULLIF(f.revenue, 0) * 100, 2)        AS net_margin_pct,

    -- Item 13: Current Ratio (kali, bukan %)
    ROUND(f.current_assets / NULLIF(f.current_liabilities, 0), 2) AS current_ratio,

    -- Item 14: Cash Conversion Cycle (dalam hari)
    -- DIO = berapa hari persediaan mengendap sebelum terjual
    ROUND(f.inventory / NULLIF(f.cogs, 0) * 365, 1)   AS dio_days,
    -- DSO = berapa hari piutang cair jadi kas
    ROUND(f.receivables / NULLIF(f.revenue, 0) * 365, 1) AS dso_days,
    -- DPO = berapa hari perusahaan menunda bayar ke supplier
    ROUND(f.payables / NULLIF(f.cogs, 0) * 365, 1)    AS dpo_days,
    -- CCC = DIO + DSO - DPO (makin kecil/negatif makin efisien modal kerjanya)
    ROUND(
        (f.inventory / NULLIF(f.cogs, 0) * 365)
        + (f.receivables / NULLIF(f.revenue, 0) * 365)
        - (f.payables / NULLIF(f.cogs, 0) * 365)
    , 1) AS ccc_days,

    -- kolom mentah ikut disertakan, berguna untuk validasi manual di Item 16
    f.revenue, f.cogs, f.gross_profit, f.operating_profit, f.net_profit,
    f.current_assets, f.current_liabilities, f.inventory, f.receivables, f.payables

FROM fact_financials f
JOIN dim_company c ON c.company_id = f.company_id
JOIN dim_period  p ON p.period_id  = f.period_id;

-- Cek hasilnya:
SELECT ticker, fiscal_year, gross_margin_pct, operating_margin_pct, net_margin_pct,
       current_ratio, ccc_days
FROM v_ratios
ORDER BY ticker, fiscal_year;


-- ============================================================
-- ITEM 15: YoY Growth pakai window function LAG()
-- ============================================================

CREATE VIEW v_yoy_growth AS
SELECT
    ticker,
    fiscal_year,
    revenue,
    net_profit,
    net_margin_pct,

    -- LAG() ambil nilai dari baris "tahun sebelumnya" dalam grup emiten yang sama.
    -- PARTITION BY ticker = hitung per emiten terpisah, jangan ketuker antar emiten.
    -- ORDER BY fiscal_year = urutan waktunya harus benar biar "sebelumnya" itu akurat.
    LAG(revenue) OVER (PARTITION BY ticker ORDER BY fiscal_year)     AS revenue_prev_year,
    LAG(net_profit) OVER (PARTITION BY ticker ORDER BY fiscal_year) AS net_profit_prev_year,
    LAG(net_margin_pct) OVER (PARTITION BY ticker ORDER BY fiscal_year) AS net_margin_prev_year,

    -- Growth % = (tahun ini - tahun lalu) / tahun lalu * 100
    ROUND(
        (revenue - LAG(revenue) OVER (PARTITION BY ticker ORDER BY fiscal_year))
        / NULLIF(LAG(revenue) OVER (PARTITION BY ticker ORDER BY fiscal_year), 0) * 100
    , 2) AS revenue_growth_yoy_pct,

    ROUND(
        (net_profit - LAG(net_profit) OVER (PARTITION BY ticker ORDER BY fiscal_year))
        / NULLIF(LAG(net_profit) OVER (PARTITION BY ticker ORDER BY fiscal_year), 0) * 100
    , 2) AS net_profit_growth_yoy_pct,

    -- Selisih margin dalam poin persentase (bukan % growth, tapi selisih langsung -
    -- lebih umum dipakai untuk baca "membaik/memburuk" di finance)
    ROUND(
        net_margin_pct - LAG(net_margin_pct) OVER (PARTITION BY ticker ORDER BY fiscal_year)
    , 2) AS net_margin_change_ppt

FROM v_ratios;

-- Cek hasilnya (2022 pasti NULL semua di kolom growth — wajar, tidak ada "tahun sebelumnya"):
SELECT ticker, fiscal_year, revenue, revenue_prev_year, revenue_growth_yoy_pct,
       net_margin_pct, net_margin_change_ppt
FROM v_yoy_growth
ORDER BY ticker, fiscal_year;


-- ============================================================
-- ITEM 16: Validasi manual — pilih 2 emiten, cross-check hitungan
-- ============================================================

-- Contoh: validasi ASII 2022
-- Ambil angka mentahnya, lalu hitung manual pakai kalkulator/Excel,
-- cocokkan dengan hasil kolom gross_margin_pct dkk di bawah.
SELECT ticker, fiscal_year, revenue, cogs, gross_profit, operating_profit, net_profit,
       current_assets, current_liabilities, inventory, receivables, payables,
       gross_margin_pct, operating_margin_pct, net_margin_pct, current_ratio, ccc_days
FROM v_ratios
WHERE ticker = 'ASII' AND fiscal_year = 2022;

-- Ganti ticker & fiscal_year di atas untuk emiten kedua yang mau divalidasi
-- (pilih 1 emiten konglomerasi kayak ASII/IMAS, dan 1 emiten manufaktur murni
--  kayak SMSM/INDS — supaya validasi mengecek dua tipe struktur data sekaligus)
