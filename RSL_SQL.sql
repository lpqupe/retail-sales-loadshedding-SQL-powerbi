-- Retail Sales & Loadshedding_project --
USE CATALOG keaggel_exercises;
USE SCHEMA default;
----- 1. CLEAN SALES DATA----------------------------------------------
CREATE OR REPLACE TABLE keaggel_exercises.default.sales_clean AS
SELECT
    to_date(Date)                                           AS sale_date,
    CASE
        WHEN TRIM(Category) IN ('Nan','NaN?','Null','') OR Category IS NULL
            THEN NULL
        ELSE TRIM(Category)
    END                                                      AS category,
    CASE
        WHEN TRIM(Sales) IN ('Nan','NaN?','Null','') OR Sales IS NULL
            THEN NULL
        WHEN isnan(TRY_CAST(TRIM(Sales) AS DOUBLE))
            THEN NULL
        ELSE TRY_CAST(TRIM(Sales) AS DOUBLE)
    END                                                      AS sales_amount,
    CASE
        WHEN TRIM(Quantity) IN ('Nan','NaN?','Null','') OR Quantity IS NULL
            THEN NULL
        WHEN isnan(TRY_CAST(TRIM(Quantity) AS DOUBLE))
            THEN NULL
        ELSE TRY_CAST(TRIM(Quantity) AS DOUBLE)
    END                                                      AS quantity,
    Profit                                                    AS profit,
    CASE
        WHEN TRIM(Region) IN ('Nan','NaN?','Null','') OR Region IS NULL
            THEN NULL
        ELSE TRIM(Region)
    END                                                      AS region
FROM retail_sales_loadshedding_project_1;
CREATE OR REPLACE TABLE keaggel_exercises.default.sales_clean AS
SELECT
    *,
    CASE
        WHEN category IS NULL OR region IS NULL
          OR sales_amount IS NULL OR quantity IS NULL
        THEN 1 ELSE 0
    END AS is_incomplete
FROM sales_clean;

----2. Loadshedding Data -----
CREATE OR REPLACE TABLE keaggel_exercises.default.loadshedding_clean AS
SELECT
    to_date(`loadshedding schuduled `)                      AS outage_date,
    date_format(`loadshedding schuduled `, 'HH:mm:ss')      AS outage_time,
    CASE WHEN TRIM(Stage) = '-' THEN NULL
         ELSE CAST(TRIM(Stage) AS INT)
    END                                                      AS stage,
    `Possible Hours-off`                                     AS hours_off,
    `Avg Disel Cost per Hour @ R28.00`                        AS diesel_cost,
    CASE WHEN hour(`loadshedding schuduled `) >= 12
         THEN 1 ELSE 0
    END                                                      AS is_afternoon_outage
FROM keaggel_exercises.default.loadshedding_shedding_2023;

--3. Agregating loadshedding on daily schedule --
CREATE OR REPLACE TABLE keaggel_exercises.default.loadshedding_daily AS
SELECT
    outage_date,
    SUM(hours_off)                                            AS total_hours_off,
    MAX(stage)                                                AS max_stage,
    COUNT(*)                                                  AS num_outages,
    SUM(diesel_cost)                                          AS total_diesel_cost,
    MAX(is_afternoon_outage)                                  AS had_afternoon_outage,
    MAX(CASE WHEN is_afternoon_outage = 0 THEN 1 ELSE 0 END)  AS had_morning_outage
FROM keaggel_exercises.default.loadshedding_clean
GROUP BY outage_date;

--4. Left Join on the Sales during loadshedding --
CREATE OR REPLACE TABLE keaggel_exercises.default.sales_loadshedding_joined AS
SELECT
    s.sale_date,
    s.category,
    s.region,
    s.sales_amount,
    s.quantity,
    s.profit,
    s.is_incomplete,
    COALESCE(l.total_hours_off, 0)        AS total_hours_off,
    l.max_stage,
    COALESCE(l.num_outages, 0)            AS num_outages,
    COALESCE(l.total_diesel_cost, 0)      AS total_diesel_cost,
    COALESCE(l.had_afternoon_outage, 0)   AS had_afternoon_outage,
    COALESCE(l.had_morning_outage, 0)     AS had_morning_outage,
    CASE WHEN l.outage_date IS NOT NULL THEN 1 ELSE 0 END AS had_outage_day
FROM keaggel_exercises.default.sales_clean s
LEFT JOIN keaggel_exercises.default.loadshedding_daily l
    ON s.sale_date = l.outage_date;

-- Dashboard base Tables --
CREATE OR REPLACE VIEW keaggel_exercises.default.vw_dashboard_base AS
SELECT
    sale_date,
    category,
    region,
    sales_amount,
    quantity,
    profit,
    is_incomplete,
    total_hours_off,
    num_outages,
    total_diesel_cost,
    had_afternoon_outage,
    had_morning_outage,
    had_outage_day,
    CASE WHEN had_outage_day = 1 THEN 'Outage Day' ELSE 'Normal Day' END AS day_type,
    COALESCE(max_stage, 0)                                               AS stage,
    CASE
        WHEN max_stage IS NULL           THEN 'No Outage'
        WHEN max_stage BETWEEN 1 AND 2   THEN 'Stage 1-2 (Low)'
        WHEN max_stage BETWEEN 3 AND 4   THEN 'Stage 3-4 (Medium)'
        WHEN max_stage >= 5              THEN 'Stage 5+ (High)'
    END                                                                   AS stage_band,
    date_format(sale_date, 'EEEE')                                       AS day_of_week,
    date_format(sale_date, 'MMMM')                                       AS month_name,
    date_format(sale_date, 'yyyy-MM')                                    AS year_month
FROM keaggel_exercises.default.sales_loadshedding_joined;

-- Executive scorecard --
CREATE OR REPLACE VIEW keaggel_exercises.default.vw_executive_summary AS
WITH daily AS (
    SELECT
        sale_date, had_outage_day, total_diesel_cost,
        SUM(sales_amount) AS daily_sales,
        SUM(profit)        AS daily_profit
    FROM keaggel_exercises.default.vw_dashboard_base
    GROUP BY sale_date, had_outage_day, total_diesel_cost
),
normal AS (
    SELECT AVG(daily_sales) AS avg_normal_sales, AVG(daily_profit) AS avg_normal_profit
    FROM daily WHERE had_outage_day = 0
),
outage AS (
    SELECT AVG(daily_sales) AS avg_outage_sales, AVG(daily_profit) AS avg_outage_profit,
           SUM(total_diesel_cost) AS total_diesel_spend
    FROM daily WHERE had_outage_day = 1
)
SELECT
    (SELECT COUNT(DISTINCT sale_date) FROM daily)                          AS total_days,
    (SELECT COUNT(DISTINCT sale_date) FROM daily WHERE had_outage_day = 1) AS total_outage_days,
    (SELECT SUM(sales_amount) FROM keaggel_exercises.default.vw_dashboard_base) AS total_sales,
    (SELECT SUM(profit) FROM keaggel_exercises.default.vw_dashboard_base)       AS total_profit,
    ROUND(n.avg_normal_sales, 2)                                           AS avg_daily_sales_normal,
    ROUND(o.avg_outage_sales, 2)                                           AS avg_daily_sales_outage,
    ROUND((o.avg_outage_sales - n.avg_normal_sales) / n.avg_normal_sales * 100, 1) AS pct_sales_impact,
    ROUND(n.avg_normal_profit, 2)                                          AS avg_daily_profit_normal,
    ROUND(o.avg_outage_profit, 2)                                          AS avg_daily_profit_outage,
    ROUND((o.avg_outage_profit - n.avg_normal_profit) / n.avg_normal_profit * 100, 1) AS pct_profit_impact,
    ROUND(o.total_diesel_spend, 2)                                         AS total_diesel_spend,
    ROUND((n.avg_normal_profit - o.avg_outage_profit)
        * (SELECT COUNT(DISTINCT sale_date) FROM daily WHERE had_outage_day = 1), 2) AS estimated_total_profit_lost
FROM normal n
CROSS JOIN outage o;

--Preview--
SELECT * FROM keaggel_exercises.default.vw_dashboard_base LIMIT 20;
SELECT * FROM keaggel_exercises.default.vw_executive_summary;

SELECT pct_sales_impact, pct_profit_impact FROM keaggel_exercises.default.vw_executive_summary;
