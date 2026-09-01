# Analisis Tren Profitabilitas & Efisiensi Modal Kerja — Emiten Otomotif IDX (2022-2025)

## Business Question

Bagaimana tren profitabilitas dan efisiensi modal kerja emiten sektor otomotif yang terdaftar di Bursa Efek Indonesia (BEI) selama periode 2022-2025? Emiten mana yang menunjukkan kombinasi profitabilitas dan efisiensi modal kerja paling baik, dan mana yang perlu perhatian?

## Kenapa Topik Ini

Analisis ini dibangun dari pengalaman 8 tahun bekerja sebagai tax & finance compliance. Alih-alih menganalisis kepatuhan pajak, project ini memindahkan lensa ke performa finansial — profitabilitas dan efisiensi arus kas operasional — pada level industri.

## Cakupan Data

- **Emiten**: ASII, AUTO, BOLT, GJTL, IMAS, INDS, SMSM (7 emiten otomotif & komponen di BEI)
- **Periode**: Tahun fiskal 2022-2025 (data tahunan)
- **Sumber**: Laporan keuangan tahunan resmi masing-masing emiten (idx.co.id)

## Metrik yang Dianalisis

| Metrik | Definisi | Formula |
|---|---|---|
| Gross Margin % | Efisiensi biaya produksi/pembelian barang | Gross Profit / Revenue × 100 |
| Operating Margin % | Efisiensi operasi inti (setelah beban penjualan & administrasi) | Operating Profit / Revenue × 100 |
| Net Margin % | Profitabilitas akhir setelah semua beban, bunga, dan pajak | Net Profit / Revenue × 100 |
| Current Ratio | Kemampuan membayar kewajiban jangka pendek | Current Assets / Current Liabilities |
| DIO (Days Inventory Outstanding) | Rata-rata hari persediaan mengendap sebelum terjual | Inventory / COGS × 365 |
| DSO (Days Sales Outstanding) | Rata-rata hari piutang cair menjadi kas | Receivables / Revenue × 365 |
| DPO (Days Payable Outstanding) | Rata-rata hari perusahaan menunda pembayaran ke supplier | Payables / COGS × 365 |
| CCC (Cash Conversion Cycle) | Total hari modal kerja "terkunci" dalam siklus operasional — makin kecil makin efisien | DIO + DSO − DPO |

## Metodologi

1. **Data extraction & cleaning** — laporan keuangan tahunan 7 emiten diekstrak manual dari dokumen resmi IDX, dibersihkan dan distandardisasi ke format tabular.
2. **Database design** — data dimodelkan dalam star schema (`fact_financials`, `dim_company`, `dim_period`) di PostgreSQL.
3. **SQL analysis** — kalkulasi rasio dan analisis tren year-over-year menggunakan CTE dan window function (`LAG()`).
4. **Dashboard** — data model, DAX measures, dan visualisasi dibangun di Power BI, menghitung ulang seluruh rasio secara independen dari SQL sebagai validasi silang.

## Key Insights

**1. SMSM memimpin dari sisi profitabilitas, tapi paling lemah dari sisi efisiensi modal kerja.**
Net margin SMSM konsisten tertinggi di antara ketujuh emiten (~24% di 2025), namun CCC-nya juga yang terpanjang (~178 hari) — mengindikasikan modal kerja yang signifikan tertahan dalam siklus operasional meskipun marginnya tinggi.

**2. ASII menunjukkan keseimbangan profitabilitas dan efisiensi paling baik.**
Dengan net margin ~16% (tertinggi kedua) dan CCC terpendek di antara seluruh emiten (~72 hari), ASII secara proporsional lebih efisien mengonversi modal kerja menjadi kas dibanding SMSM — menjadikannya kandidat paling solid ketika profitabilitas dan efisiensi modal kerja dipertimbangkan bersamaan, bukan hanya margin semata.

**3. IMAS memerlukan perhatian pada kedua dimensi.**
IMAS mencatat net margin terendah (~3%) sekaligus CCC yang panjang (~165 hari) — kombinasi profitabilitas rendah dan modal kerja yang kurang efisien.

**4. GJTL menunjukkan pemulihan margin yang tajam.**
Net margin GJTL bergerak dari negatif di 2022 menuju positif secara konsisten hingga 2025, pola yang berbeda dari emiten lain yang cenderung stabil sepanjang periode.

## Batasan & Simplifikasi

- **DIO/DSO/DPO dihitung menggunakan saldo akhir tahun**, bukan rata-rata saldo awal-akhir tahun. Pendekatan rata-rata umumnya lebih presisi secara akademis, namun saldo akhir dipilih untuk menjaga scope analisis tetap ringkas dan dapat diselesaikan dalam waktu terbatas.
- **Piutang, persediaan, dan utang emiten konglomerasi (ASII, IMAS)** difilter untuk hanya mencakup item dari segmen operasi inti otomotif (trade receivables, persediaan operasional), mengecualikan piutang/persediaan dari segmen non-inti seperti jasa keuangan, real estat, atau agribisnis.
- **Operating profit** tidak tersedia secara eksplisit dalam taksonomi pelaporan IDX, sehingga dihitung manual sebagai Gross Profit − Beban Penjualan − Beban Umum dan Administrasi.

## Tech Stack

`PostgreSQL` · `SQL (CTE, Window Functions)` · `Power BI` · `DAX`

## Rencana Pengembangan Lanjutan

Fase berikutnya akan memperluas kompleksitas SQL, menambah data kuartalan, dan mengintegrasikan analisis dari Project 7-8.
