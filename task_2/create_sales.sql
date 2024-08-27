-- public.sales определение

-- Drop table

-- DROP TABLE public.sales;

CREATE TABLE public.sales (
	sale_dt varchar(10) NULL,
	product_offer varchar(255) NULL,
	employee_id varchar(20) NULL,
	client_id varchar(30) NULL,
	sale_qty int4 NULL
);