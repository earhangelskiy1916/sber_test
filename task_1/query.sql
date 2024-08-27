WITH filtered_data AS (
    SELECT 
        report_dt, 
        start_dt::DATE, 
        end_dt::DATE, 
        fact_post, 
        block_name, 
        org_type, 
        urf_code,
        saphr_id
    FROM 
        csvtask1
    WHERE 
        block_name = 'Блок 1' 
        AND org_type = 'Тип 1'
),
sorted_data AS (
    SELECT 
        *,
        LAG(end_dt::DATE) OVER (PARTITION BY saphr_id, fact_post, urf_code ORDER BY start_dt::DATE) AS prev_end_dt
    FROM 
        filtered_data
),
periods AS (
    SELECT 
        *,
        CASE 
            WHEN start_dt::DATE != prev_end_dt + INTERVAL '1 day' THEN 1
            ELSE 0 
        END AS new_period_flag
    FROM 
        sorted_data
),
grouped_periods AS (
    SELECT 
        *,
        SUM(new_period_flag) OVER (PARTITION BY saphr_id, fact_post, urf_code ORDER BY start_dt::DATE) AS period_group_id
    FROM 
        periods
)
SELECT 
    saphr_id, 
    fact_post, 
    urf_code, 
    MIN(start_dt::DATE) AS start_dt, 
    MAX(end_dt::DATE) AS end_dt
FROM 
    grouped_periods
GROUP BY 
    saphr_id, fact_post, urf_code, period_group_id
ORDER BY 
    saphr_id, start_dt;
