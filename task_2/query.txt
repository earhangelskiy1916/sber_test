INSERT INTO "WITH product_offers AS (
    SELECT 
        CASE 
            WHEN o.visit_dt ~ '^\d+$' THEN TO_DATE('1899-12-30', 'YYYY-MM-DD') + (o.visit_dt::INTEGER) 
            ELSE TO_DATE(o.visit_dt, 'DD.MM.YYYY')
        END AS visit_dt,
        p.product,
        o.product_offer,
        o.employee_id,
        o.client_id,
        CAST(o.offer_qty AS INTEGER) AS offer_qty
    FROM 
        Offers o
    JOIN 
        Products p ON o.product_offer = p.product_offer
),
product_sales AS (
    SELECT 
        CASE 
            WHEN s.sale_dt ~ '^\d+$' THEN TO_DATE('1899-12-30', 'YYYY-MM-DD') + (s.sale_dt::INTEGER) 
            ELSE TO_DATE(s.sale_dt, 'DD.MM.YYYY')
        END AS sale_dt,
        p.product,
        s.product_offer,
        s.employee_id,
        s.client_id,
        CAST(s.sale_qty AS INTEGER) AS sale_qty
    FROM 
        Sales s
    JOIN 
        Products p ON s.product_offer = p.product_offer
),
monthly_offers AS (
    SELECT 
        DATE_TRUNC('month', po.visit_dt) AS month_dt,
        po.product,
        SUM(po.offer_qty) AS total_offers
    FROM 
        product_offers po
    GROUP BY 
        month_dt, po.product
),
monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', ps.sale_dt) AS month_dt,
        ps.product,
        SUM(ps.sale_qty) AS total_sales
    FROM 
        product_sales ps
    WHERE 
        EXISTS (
            SELECT 1 
            FROM product_offers po
            WHERE 
                po.product = ps.product
                AND po.client_id = ps.client_id
                AND ps.sale_dt BETWEEN po.visit_dt AND po.visit_dt + INTERVAL '30 days'
        )
    GROUP BY 
        month_dt, ps.product
)
SELECT 
    mo.month_dt,
    mo.product,
    mo.total_offers AS offer_qty,
    COALESCE(ms.total_sales, 0) AS sale_qty,
    COALESCE(ms.total_sales::FLOAT / NULLIF(mo.total_offers, 0), 0) AS conversion
FROM 
    monthly_offers mo
LEFT JOIN 
    monthly_sales ms ON mo.month_dt = ms.month_dt AND mo.product = ms.product
ORDER BY 
    mo.month_dt, mo.product" (month_dt,product,offer_qty,sale_qty,"conversion") VALUES
	 ('2023-03-01 00:00:00+03','Продукт 1',85346,5476,0.06416235090103813),
	 ('2023-03-01 00:00:00+03','Продукт 2',170859,43728,0.25593032851649605);
