
-- CREATE TABLE test_data AS
WITH pre AS (SELECT
--             ROW_NUMBER() OVER (PARTITION BY ID)         rnk,
CAST(CASE
         WHEN TRIM(LOWER(STATUS)) IN
              ('cancelled', 'canceled', 'cancelled during production') -- recategorize status options
             THEN 'cancelled'
         WHEN TRIM(LOWER(STATUS)) IN ('printed', 'picked', 'packaged') THEN 'processing'
         WHEN TRIM(LOWER(STATUS)) IN ('shipped', 'dispatched - shipped') THEN 'shipped'
         WHEN TRIM(LOWER(STATUS)) = 'bad-cut-path' THEN 'bad_cut_path'
         WHEN TRIM(LOWER(STATUS)) = 'on-hold' THEN 'on_hold'
         WHEN STATUS IS NULL THEN 'shipped'

         ELSE TRIM(LOWER(STATUS))
    END AS TEXT)                         AS fr_status,

CAST(CASE
         WHEN UPPER(COUNTRY) IN ('SWEDEN') THEN 'SE' -- Conversion to ISO codes
         WHEN UPPER(COUNTRY) IN ('KERZELL') THEN 'LE'
         WHEN UPPER(COUNTRY) IN ('NORWAY') THEN 'NO'
         WHEN UPPER(COUNTRY) IN ('UNITED STATES', 'USA') THEN 'US'
         WHEN UPPER(COUNTRY) IN ('ITALY') THEN 'IT'
         WHEN UPPER(COUNTRY) IN ('RIYADH') THEN 'SA' -- Assuming 'ryadh' was a typo.
         WHEN UPPER(COUNTRY) IN ('LATVIA') THEN 'LV'
         WHEN UPPER(COUNTRY) IN ('UNITED KINGDOM', 'LONDON') THEN 'GB'
         WHEN UPPER(COUNTRY) IN ('ISRAEL') THEN 'IL'
         WHEN UPPER(COUNTRY) IN ('SOUTH AFRICA') THEN 'ZA'
         WHEN UPPER(COUNTRY) IN ('UKRAINE') THEN 'UA'
         WHEN UPPER(COUNTRY) IN ('ESTONIA') THEN 'EE'
         WHEN UPPER(COUNTRY) IN ('QATAR') THEN 'QA'
         WHEN UPPER(COUNTRY) IN ('GABORONE') THEN 'BW' -- Assuming Gaborone represents Botswana.
         WHEN UPPER(COUNTRY) IN ('FRANCE') THEN 'FR'
         WHEN UPPER(COUNTRY) IN ('PUERTO RICO') THEN 'PR'
         WHEN UPPER(COUNTRY) IN ('ATHENS') THEN 'GR' -- Assuming Athens represents Greece.
         WHEN UPPER(COUNTRY) IN ('POLAND') THEN 'PL'
         WHEN UPPER(COUNTRY) IN ('INDONESIA') THEN 'ID'
         WHEN UPPER(COUNTRY) IN ('MALDIVES') THEN 'MV'
         WHEN UPPER(COUNTRY) IN ('ZEMUN') THEN 'RS' -- Assuming Zemun represents Serbia.
         WHEN UPPER(COUNTRY) IN ('GERMANY') THEN 'DE'
         WHEN UPPER(COUNTRY) IN ('CANADA') THEN 'CA'
         WHEN UPPER(COUNTRY) IN ('SERBIA') THEN 'RS'
         WHEN UPPER(COUNTRY) IN ('NEW TAIPEI CITY')
             THEN 'TW' -- Assuming New Taipei City represents Taiwan.
         WHEN UPPER(COUNTRY) IN ('RUSSIAN FEDERATION') THEN 'RU'
         WHEN UPPER(COUNTRY) IN ('JERSEY') THEN 'JE'
         WHEN UPPER(COUNTRY) IN ('UNITED ARAB EMIRATES') THEN 'AE'
         WHEN UPPER(COUNTRY) IN ('KENYA') THEN 'KE'
         WHEN UPPER(COUNTRY) IN ('SAUDI ARABIA') THEN 'SA'
         WHEN UPPER(COUNTRY) IN ('BAHRAIN') THEN 'BH'
         WHEN UPPER(COUNTRY) IN ('LIECHTENSTEIN') THEN 'LI'
         WHEN UPPER(COUNTRY) IN ('FINLAND') THEN 'FI'
         WHEN UPPER(COUNTRY) LIKE '%HERMITAGE%' THEN 'UK'
         WHEN UPPER(COUNTRY) LIKE '%SHIP%' THEN 'UNK'
         WHEN UPPER(COUNTRY) LIKE '%THUWAL%' THEN 'SA'
         WHEN UPPER(COUNTRY) LIKE '%TAIWAN%' THEN 'TA'
         WHEN UPPER(COUNTRY) LIKE '%RYADH%' THEN 'SA'
         WHEN COUNTRY LIKE '%560213%' OR COUNTRY IS NULL THEN 'UNK'
         WHEN UPPER(COUNTRY) IN ('JAPAN') THEN 'JP'
         ELSE UPPER(COUNTRY)
    END AS TEXT)                         as 'fr_country',
CAST(
        CASE
            WHEN ORDER_CREATED_DATE IS NULL THEN '00:00.0'
            ELSE ORDER_CREATED_DATE
            END AS TEXT)                    'fr_order_created_date',
CAST(
        CASE
            WHEN SHIP_DATE IS NULL OR SHIP_STATE = 'SC' THEN '00:00.0'
            ELSE SHIP_DATE
            END AS TEXT)                 as fr_ship_date,

--     CAST(ifnull(TAX_RATE, 0) AS REAL) as 'fr_tax_rate'  -> no tax information
--     CAST(ifnull(TAX, 0) AS REAL) as 'fr_tax' -> no tax information
--     CAST(COALESCE(ITEM_QUANTITY, 0) as INTEGER) as 'fr_item_quantity',
--     CAST(COALESCE(PRODUCT_COSTS, 0) as REAL) as fr_product_costs -- zero means there is no production cost, null is no production info at all
        CAST(COALESCE(HANDLING_COST, 0) as REAL) as fr_handling_cost,
CASE
    WHEN length(SHIP_STATE) > 2 THEN SHIP_STATE || '- needs one format'
    ELSE SHIP_STATE
    END                                  as fr_ship_state,
*
             FROM Invoiced_item
             WHERE length(ORDER_CREATED_DATE) != 2)


SELECT

  *,

   fr_status,
   fr_country,
   fr_handling_cost,
   fr_order_created_date,
--         fr_product_costs,
   fr_ship_date

FROM pre;
